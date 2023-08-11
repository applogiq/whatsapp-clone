import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:whatsapp_ui/common/utils/utils.dart';

class GroupPushNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  setupFirebaseMessaging(String head, String sub) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(head, sub);
    });
  }

  Future<void> showNotification(String head, String sub) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(0, head, sub, platformChannelSpecifics,
        payload: 'foreground_notification');
  }

  void sendPushNotifications(List<String> deviceTokens, String title,
      String body, BuildContext ctx) async {
    try {
      String serverKey = "YOUR_SERVER_KEY";
      String url = 'https://fcm.google        apis.com/fcm/send';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      };

      Map<String, dynamic> notification = {
        'title': title,
        'body': body,
      };

      Map<String, dynamic> data = {
        // Optional data payload
        // ...
      };

      List<Map<String, dynamic>> messages = deviceTokens.map((token) {
        return {
          'to': token,
          'notification': notification,
          'data': data,
        };
      }).toList();

      Map<String, dynamic> payload = {
        'messages': messages,
      };

      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(payload));

      if (response.statusCode == 200) {
        await setupFirebaseMessaging(title, body);
      } else {
        // Handle error response
      }
    } catch (e) {
      showSnackBar(context: ctx, content: e.toString());
    }
  }
}
