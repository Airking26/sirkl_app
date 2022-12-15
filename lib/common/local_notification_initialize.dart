import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';

class LocalNotificationInitialize{

  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());

  Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async{
    var androidInitialize = const AndroidInitializationSettings("@mipmap/notif");
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
    );
  }

  void onDidReceiveLocalNotification(NotificationResponse notificationResponse) async {
    _navigationController.changeCurrentPage(3);
    _navigationController.pageController.value.jumpToPage(3);
    await _commonController.getUserById("6399c4bbf7d2390029566622");
    Get.to(() => const DetailedChatScreen(create: true,));
  }

  static Future showBigTextNotification({required String title, required String body, var payload, required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin}) async {
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails("sirkl_notifications_id", "sirkl_notifications_channel", playSound: true, importance: Importance.max, priority: Priority.max);
    var notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: const DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}