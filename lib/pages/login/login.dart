import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rolebase/pages/home_page.dart';
import 'package:rolebase/pages/login/forgot.dart';
import 'package:rolebase/pages/login/register.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/my_drawer.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
     int _currentIndex = 3;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;

Future<void> _login() async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
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
          'Logged in successfully!',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('User logged in successfully!');
  } catch (e) {
    print('Failed to log in user: $e');
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFF8340),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          side: BorderSide(
            color: const Color(0xFFFF8340),
            width: 2.0,
          ),
        ),
        content: Text(
          'Failed to log in user: $e',
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
                Image.asset(
                  './images/img3.png', 
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
                const SizedBox(height: 10.0),
                Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            // Implement forgot password functionality
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF56C6D3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                  ),
                  const SizedBox(height: 5.0),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 20), 
                    backgroundColor: const Color(0xFF56C6D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                   child: const Text(
                    'Login', 
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
                        builder: (context) => RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Sign up',
                    style: TextStyle(
                      color: Color(0xFF56C6D3),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        height: 20,
                        thickness: 2,
                        color: Color(0xFF56C6D3),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        height: 20,
                        thickness: 2,
                        color: Color(0xFF56C6D3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle Google sign-in
                  },
                  icon: Image.asset(
                    './images/google.png', 
                    width: 20.0,
                  ),
                  label: Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary, 
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 85, vertical: 15),
                  ),
                ),
                const SizedBox(height: 10),
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
