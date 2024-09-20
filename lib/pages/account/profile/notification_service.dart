import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Replace with your actual channel details
  static const String _channelId = 'schedule_channel';
  static const String _channelName = 'Schedule Notifications';
  static const String _channelDescription = 'Notifications for schedule events';

    NotificationService() {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

 Future<void> scheduleNotification(DateTime scheduleTime) async {
    tz.initializeTimeZones();
    final scheduledDate = tz.TZDateTime.from(scheduleTime, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          _channelId, 
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Event Reminder',
      'You have an upcoming event!',
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      payload: 'item x',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Future<void> scheduleNotification(DateTime scheduleTime) async {
  //   tz.initializeTimeZones();
  //   final scheduledDate = tz.TZDateTime.from(scheduleTime, tz.local);

  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //         _channelId, 
  //         _channelName,
  //         channelDescription: _channelDescription,
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         ticker: 'ticker',
  //       );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await _flutterLocalNotificationsPlugin.zonedSchedule(
  //     0,
  //     'Event Reminder',
  //     'You have an upcoming event!',
  //     scheduledDate,
  //     platformChannelSpecifics,
  //     androidAllowWhileIdle: true,
  //     payload: 'item x',
  //     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }

  Future<void> saveSchedule(DateTime dateTime, String time, String note) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('User not logged in');
    }

    if (dateTime == null || time.isEmpty || note.isEmpty) {
      throw Exception('Invalid schedule data');
    }

    // Generate a unique ID for the document
    final customId = 'schedule_${dateTime.toIso8601String()}_${time.replaceAll(':', '_')}';

    final scheduleRef = _firestore.collection('users').doc(userId).collection('schedules').doc(customId);

    await scheduleRef.set({
      'date': Timestamp.fromDate(dateTime),
      'day': _formatDay(dateTime),
      'time': time,
      'note': note,
    });

    await saveNotification('New Schedule Added', 'You have a new schedule on ${dateTime.toLocal()}');
    await scheduleNotification(dateTime);
  }

  Future<void> saveNotification(String title, String body) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final notificationRef = _firestore.collection('users').doc(userId).collection('notifications').doc();

    await notificationRef.set({
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(DateTime.now()), // Store the current time
    });
  }

  String _formatDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}