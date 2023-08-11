import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:whatsapp_ui/common/utils/utils.dart';

class PushNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  PushNotification() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // final initializationSettingsIOS = IOSInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == 'id1') {
            } else if (notificationResponse.actionId == 'id2') {}
            break;
        }
      },
    );
  }

  setupFirebaseMessaging(String head, String sub) {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        await showNotification(head, sub);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
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
      actions: [
        AndroidNotificationAction(
          "id1",
          "Accept",
          titleColor: Colors.green,
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          "id2",
          "Decline",
          titleColor: Colors.red,
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
      ongoing: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, head, sub, platformChannelSpecifics,
        payload: 'foreground_notification');
    Timer(const Duration(minutes: 1), () async {
      await flutterLocalNotificationsPlugin.cancel(0);
    });
  }

  Future<void> sendPushNotification(
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
