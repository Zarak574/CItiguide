import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:rolebase/pages/account/profile/notification_screen.dart';
import 'package:rolebase/widgets/custom_icon_button.dart';
import '../pages/account/profile/notification_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key}) : super(key: key);

  final NotificationService _notificationService = NotificationService();

  Future<String?> _getUserProfileImageUrl(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['photoUrl'];
    }
    return null;
  }

  void _onNotificationIconPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: const Color(0xFFD4EFFF),
      backgroundColor: Theme.of(context).colorScheme.background,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Stack(
                children: [
                  CustomIconButton(
                    icon: const Icon(Ionicons.notifications),
                    onPressed: () => _onNotificationIconPressed(context),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 12,
                        maxHeight: 12,
                      ),
                      child: const Center(
                        child: Text(
                          '3', // Replace with the number of unread notifications
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
