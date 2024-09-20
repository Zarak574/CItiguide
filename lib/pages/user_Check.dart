import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? userId = getUserId();

    return Scaffold(
      appBar: AppBar(
        title: Text('User UID'),
      ),
      body: Center(
        child: userId != null
            ? Text('User UID: $userId')
            : Text('No user logged in'),
      ),
    );
  }

  // Method to check if user is logged in and retrieve UID
  String? getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return null; // User is not logged in
    }
  }
}
