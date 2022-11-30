import 'dart:async';
import 'dart:io';

import 'package:callkeep/callkeep.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/common/language.dart';
import 'package:sirkl/common/model/collection_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/firebase_options.dart';
import 'package:sirkl/home/controller/home_controller.dart';
//import 'package:zego_zim/zego_zim.dart';

import 'common/interface/ZIMEventHandlerManager.dart';
import 'navigation/ui/navigation_screen.dart';

void main() async{
  final client = StreamChatClient(
    'v2s6zx9zjd9b',
    logLevel: Level.ALL,
  );
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  runApp(MyApp(client: client));


}

Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  final callKeep = FlutterCallkeep();
  print('backgroundMessage: message => ${message.toString()}');
  var payload = message.data;
  var callerId = payload['caller_id'] as String;
  var callerNmae = payload['caller_name'] as String;
  var uuid = payload['uuid'] as String;
  var hasVideo = payload['has_video'] == "true";

  final callUUID = uuid;
  callKeep.on(CallKeepPerformAnswerCallAction(),
          (CallKeepPerformAnswerCallAction event) {
        print(
            'backgroundMessage: CallKeepPerformAnswerCallAction ${event.callUUID}');
        Timer(const Duration(seconds: 1), () {
          print(
              '[setCurrentCallActive] $callUUID, callerId: $callerId, callerName: $callerNmae');
          callKeep.setCurrentCallActive(callUUID);
        });
        //_callKeep.endCall(event.callUUID);
      });

  callKeep.on(CallKeepPerformEndCallAction(),
          (CallKeepPerformEndCallAction event) {
        print('backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');
      });
  callKeep.setup(
      null,
      <String, dynamic>{
        'ios': {
          'appName': 'CallKeepDemo',
        },
        'android': {
          'alertTitle': 'Permissions required',
          'alertDescription':
          'This application needs to access your phone accounts',
          'cancelButton': 'Cancel',
          'okButton': 'ok',
          'foregroundService': {
            'channelId': 'com.company.my',
            'channelName': 'Foreground service for my app',
            'notificationTitle': 'My app is running on background',
            'notificationIcon':
            'Path to the resource icon of the notification',
          },
        },
      },
      backgroundMode: true);

  print('backgroundMessage: displayIncomingCall ($callerId)');
  callKeep.displayIncomingCall(callUUID, callerId,
      localizedCallerName: callerNmae, hasVideo: hasVideo);
  callKeep.backToForeground();
  /*

  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print('notification => ${notification.toString()}');
  }

  // Or do other work.
  */
  await "";
}


class MyApp extends StatelessWidget {

  const MyApp({Key? key, required this.client}) : super(key: key);

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Language(),
      locale: const Locale('en'),
      builder: (context, child){
        return StreamChat(client: client, child: child,);
      },
      darkTheme: ThemeData(brightness: Brightness.dark, dividerColor: Colors.transparent),
      themeMode: ThemeMode.system,
      theme: ThemeData(brightness: Brightness.light, dividerColor: Colors.transparent),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(client: client),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.client}) : super(key: key);

  final StreamChatClient client;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _homeController = Get.put(HomeController());
  final _callController = Get.put(CallsController());

  @override
  void initState() {
    _homeController.retrieveAccessToken();
    if(_homeController.accessToken.value.isNotEmpty) _homeController.putFCMToken(widget.client);
    _callController.callKeep.on(CallKeepDidDisplayIncomingCall(), _callController.didDisplayIncomingCall);
    _callController.callKeep.on(CallKeepPerformAnswerCallAction(), _callController.answerCall);
    _callController.callKeep.on(CallKeepDidPerformDTMFAction(), _callController.didPerformDTMFAction);
    _callController.callKeep.on(
        CallKeepDidReceiveStartCallAction(), _callController.didReceiveStartCallAction);
    _callController.callKeep.on(CallKeepDidToggleHoldAction(), _callController.didToggleHoldCallAction);
    _callController.callKeep.on(
        CallKeepDidPerformSetMutedCallAction(), _callController.didPerformSetMutedCallAction);
    _callController.callKeep.on(CallKeepPerformEndCallAction(), _callController.endCall);
    _callController.callKeep.on(CallKeepPushKitToken(), _callController.onPushKitToken);

    _callController.callKeep.setup(context, <String, dynamic>{
      'ios': {
        'appName': 'CallKeepDemo',
      },
      'android': {
        'alertTitle': 'Permissions required',
        'alertDescription':
        'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
        'foregroundService': {
          'channelId': 'com.company.my',
          'channelName': 'Foreground service for my app',
          'notificationTitle': 'My app is running on background',
          'notificationIcon': 'Path to the resource icon of the notification',
        },
      },
    });

    if (Platform.isAndroid) {
      //if (isIOS) iOS_Permission();
      //  _firebaseMessaging.requestNotificationPermissions();

      _callController.firebaseMessaging.getToken().then((token) {
        print('[FCM] token => ' + token!);
      });

      FirebaseMessaging.onMessage.listen((event) {
        print('onMessage: $event');
        if (event.contentAvailable) {
          // Handle data message
          var payload = event.data;
          var callerId = payload['caller_id'] as String;
          var callerName = payload['caller_name'] as String;
          var uuid = payload['uuid'] as String;
          var hasVideo = payload['has_video'] == "true";
          final callUUID = uuid ?? Uuid().v4();
          setState(() {
            _callController.calls[callUUID] = Call(callerId);
          });
          _callController.callKeep.displayIncomingCall(callUUID, callerId,
              localizedCallerName: callerName, hasVideo: hasVideo);
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const NavigationScreen();
  }
}
