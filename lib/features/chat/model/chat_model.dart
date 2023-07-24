import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:whatsapp_ui/common/utils/utils.dart';

class PushNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  setupFirebaseMessaging(String head, String sub) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Received message while app is in the foreground: ${message.notification}');
      showNotification(head, sub);
    });
  }

  Future<void> showNotification(String head, String sub) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(0, head, sub, platformChannelSpecifics,
        payload: 'foreground_notification');
  }

  void sendPushNotification(
      String deviceToken, String title, String body, BuildContext ctx) async {
    try {
      String serverKey =
          // 'dSuRkgdFStK5TCSmwmRdPB:APA91bF59P6A1gyJb-QGU-WAE8IJUtKhNedHzklPEZcSMyc82TjlLNtd6_T5HqmOpkfSNIOpskSQA6s_Ur1DpwVr0p_RBIaK-euQme-qg3IGZcHSi9aV36mP8qv-B2HF4F_nkXXdfwuh';
          "AAAAVyJsNsQ:APA91bGIv7dRzt8vPKQ2_3soFOouXdWFbITca5VPQ9AJG2eVpAxZLmEKMfMVNjcGEzAq1WliCN0fiNcRRJmIHvRWJ6mfmaGDmJCjvYsTmgCu_kStLgSTRXuwFHU5EbCW7dwKOYer5V_O";
      String url = 'https://fcm.googleapis.com/fcm/send';

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

      Map<String, dynamic> payload = {
        'to': deviceToken,
        'notification': notification,
        'data': data,
      };

      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(payload));

      if (response.statusCode == 200) {
        await setupFirebaseMessaging(title, body);
      } else {}
    } catch (e) {
      showSnackBar(context: ctx, content: e.toString());
    }
  }
}
