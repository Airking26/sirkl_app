import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationInitialize{

  Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async{
    var androidInitialize = const AndroidInitializationSettings("ic_notification");
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future showBigTextNotification({required String title, required String body, var payload, required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin}) async {
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails("sirkl_notifications_id", "sirkl_notifications_channel", playSound: true, importance: Importance.high, priority: Priority.high, color: Colors.white);
    var notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: const DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}