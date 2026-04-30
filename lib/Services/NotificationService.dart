import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Initialize FCM
  Future<void> initialize(BuildContext context) async {
    // 1. Request Permission (iOS/Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // 2. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotificationSnackBar(context, message.notification!.title ?? '', message.notification!.body ?? '');
      }
    });

    // 3. Handle Background/Terminated Click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked: ${message.data}');
    });
  }

  // Save Token to Firestore
  Future<void> saveToken(String userId, {bool isAdmin = false}) async {
    String? token = await _fcm.getToken();
    if (token != null) {
      if (isAdmin) {
        // Save to admin specific settings
        await FirebaseFirestore.instance.collection('admin_settings').doc('fcm').set({
          'tokens': FieldValue.arrayUnion([token])
        }, SetOptions(merge: true));
      } else {
        // Save to user document using set with merge to avoid 'not found' errors
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmToken': token
        }, SetOptions(merge: true));
      }
    }
  }

  void _showNotificationSnackBar(BuildContext context, String title, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(body, style: TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.blue.shade900,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
