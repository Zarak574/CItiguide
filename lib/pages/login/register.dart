import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rolebase/pages/login/login.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/my_drawer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
       int _currentIndex = 3;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpassController = TextEditingController();

  String? _passwordError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

   @override
  void initState() {
    super.initState();
    _passwordError = null;
  }

  bool _passwordsMatch() {
    return _passwordController.text == _confirmpassController.text;
  }

  Future<void> _register() async {
  if (!_passwordsMatch()) {
    setState(() {
      _passwordError = "Passwords do not match.";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFF8340),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          side: BorderSide(
            color: Color(0xFFFF8340),
            width: 2.0,
          ),
        ),
        content: Text(
          _passwordError!,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    String email = _emailController.text.trim();
    String username = email.substring(0, email.indexOf('@'));

    // Removed defaultPhotoUrl and related Firestore document field
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(userCredential.user!.uid).set({
      'username': username,
      'email': _emailController.text.trim(),
      // Remove 'photoUrl' from here
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFFFF8340),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          side: BorderSide(
            color: Color(0xFFFF8340),
            width: 2.0,
          ),
        ),
        content: Text(
          'User registered successfully!',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('User registered successfully!');
  } catch (e) {
    print('Failed to register user: $e');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFF8340),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          side: BorderSide(
            color: Color(0xFFFF8340),
            width: 2.0,
          ),
        ),
        content: Text(
          'Failed to register user: $e',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(),
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // const Padding(
                //    padding: EdgeInsets.only(left: 8.0),
                //    child: HeadingWidget(title: "REGISTER"),
                //  ),
                Image.asset(
                  './images/img4.png', 
                  width: 250,
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).colorScheme.secondary,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), 
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF56C6D3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).colorScheme.secondary,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    child: TextField(
                      controller: _passwordController,
                       obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: _togglePasswordVisibility,
                          iconSize: 20.0
                        ),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF56C6D3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).colorScheme.secondary,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    child: TextField(
                      controller: _confirmpassController,
                       obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        // contentPadding: const EdgeInsets.symmetric(horizontal: 20.0,), 
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          iconSize: 20.0,
                          onPressed: _toggleConfirmPasswordVisibility,
                        ),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF56C6D3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorText: _passwordError,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 20), 
                    backgroundColor: const Color(0xFF56C6D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                   child: const Text(
                    'Sign Up', 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      ),
                    ),
                ),
                const SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      color: Color(0xFF56C6D3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
