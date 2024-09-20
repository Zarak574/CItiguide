import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rolebase/pages/account/profile/all_record_display.dart';
import 'package:rolebase/pages/login/login.dart';
import 'package:rolebase/pages/account/profile/all_users.dart';
import 'package:rolebase/pages/account/profile/bookmark.dart';
import 'package:rolebase/pages/account/profile/my_profile.dart';
import 'package:rolebase/pages/account/posts/user_posts.dart';
import 'package:rolebase/pages/settings_page.dart';
import 'package:rolebase/widgets/app_bar.dart';
import 'package:rolebase/widgets/bottom_navigation.dart';
import 'package:rolebase/widgets/my_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminProfile extends StatefulWidget {
  static String routeName = "/adminprofile";
  

  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
     int _currentIndex = 3;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  Future<String?> _getUserProfileImageUrl(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['profile_picture'];  
      }
    } catch (e) {
      print("Error fetching profile image URL: $e");
    }
    return null;
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            FutureBuilder<User?>(
              future: _getCurrentUser(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!userSnapshot.hasData) {
                  return const Center(child: Text("Error loading user data"));
                } else {
                  final user = userSnapshot.data!;
                  return FutureBuilder<String?>(
                    future: _getUserProfileImageUrl(user.uid),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF8340), width: 4),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (imageSnapshot.hasError || !imageSnapshot.hasData || imageSnapshot.data!.isEmpty) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF8340), width: 4),
                            image: const DecorationImage(
                              image: AssetImage('./images/placeholder.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFFFF8340),width: 4),
                            image: DecorationImage(
                              image: NetworkImage(imageSnapshot.data!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
           
            const SizedBox(height: 10),
            ProfileMenu(
              text: "My Profile",
              icon: "./icons/UserIcon.svg",
              press: () => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfile(),
                  ),
                )
              },
            ),
            ProfileMenu(
              text: "Posts",
              icon: "./icons/posts.svg",
              press: () => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserPosts(),
                  ),
                )
              },
            ),
            ProfileMenu(
              text: "Saved",
              icon: "./icons/bookmark.svg",
              press: () => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookmarksPage(),
                  ),
                )
              },
            ),
            ProfileMenu(
              text: "Users",
              icon: "./icons/UserIcon.svg",
              press: () {
                 Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>  AllUsers(),
                ),);
              },
            ),
            ProfileMenu(
              text: "Places",
              icon: "./icons/Discover.svg",
              press: () => {
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>  AllRecordsDisplay(),
                ),)
              },
            ),
            ProfileMenu(
              text: "Settings",
              icon: "./icons/Settings.svg",
              press: () => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                )
              },
            ),
            ProfileMenu(
              text: "Log Out",
              icon: "./icons/Logout.svg",
              press: () => logout(context),
            ),
          ],
        ),
      ),
       bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

 Future<void> logout(BuildContext context) async {
  final bool shouldLogout = await showDialog<bool>(
    context: context,
    barrierDismissible: false, 
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); 
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); 
            },
            child: Text('Logout', style: TextStyle(color: Color(0xFFFF8340),),),
          ),
        ],
      );
    },
  ) ?? false;

  
  if (shouldLogout) {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
  }) : super(key: key);

  final String text, icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              color: Color(0xFFFF8340),
              width: 22,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(text, 
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary, 
                fontSize: 14,
              ),)
            ),
          ],
        ),
      ),
    );
  }
}

