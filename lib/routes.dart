import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rolebase/pages/all_places.dart';
import 'package:rolebase/pages/home_page.dart';
import 'package:rolebase/pages/login/login.dart';
import 'package:rolebase/pages/account/profile/admin_profile.dart';
import 'package:rolebase/pages/account/profile/user_profile.dart';
import 'package:rolebase/pages/search_page.dart';
import 'package:rolebase/pages/splash/splash_screen.dart';

Future<Widget> _getProfilePage() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && user.email == 'admin@gmail.com') {
    return const AdminProfile();
  } else {
    return const UserProfile();
  }
}

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  HomePage.routeName: (context) => HomePage(),
  '/search': (context) => SearchPage(),
  '/login': (context) => const LoginPage(),
  '/allplaces': (context) => const AllPlaces(),
  '/profile': (context) {
    return FutureBuilder<Widget>(
      future: _getProfilePage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('No profile page available')),
          );
        } else {
          return snapshot.data!;
        }
      },
    );
  },
};
