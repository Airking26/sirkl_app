import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/common/language.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/firebase_options.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'navigation/ui/navigation_screen.dart';

void main() async{
  final client = StreamChatClient(
    'v2s6zx9zjd9b',
    logLevel: Level.ALL,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(MyApp(client: client));
}

Future<void> setupVoiceSDKEngine() async {
  // retrieve or request microphone permission
  await [Permission.microphone].request();

  //create an instance of the Agora engine
  var agoraEngine = await RtcEngine.create("appId");
  await agoraEngine.initialize(RtcEngineContext("appId"));

  // Register the event handler
  agoraEngine.setEventHandler(
    RtcEngineEventHandler(
      joinChannelSuccess: (String x, int y, int elapsed) {
        var t = x;
        var tr = y;
        var trr = elapsed;
      },
      userJoined: (int remoteUid, int elapsed) {
      },
      userOffline: (int remoteUid, UserOfflineReason reason) {
      },
    ),
  );
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{

  final _homeController = Get.put(HomeController());
  final _callController = Get.put(CallsController());

  @override
  void initState() {
    initFirebase();
    _homeController.putFCMToken(context, widget.client);
    super.initState();
  }

  initFirebase() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      showCallkitIncoming(message.data['uuid'] as String);
    });
    _callController.listenCall();
  }


  @override
  Widget build(BuildContext context) {
    return const NavigationScreen();
  }

}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  showCallkitIncoming(message.data['uuid'] as String);
}

Future<void> showCallkitIncoming(String uuid) async {
  var params = <String, dynamic>{
    'id': uuid,
    'nameCaller': 'Hien Nguyen',
    'appName': 'Callkit',
    'avatar': 'https://i.pravatar.cc/100',
    'handle': '0123456789',
    'type': 0,
    'duration': 30000,
    'textAccept': 'Accept',
    'textDecline': 'Decline',
    'textMissedCall': 'Missed call',
    'textCallback': 'Call back',
    'extra': <String, dynamic>{'userId': '1a2b3c4d'},
    'headers': <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    'android': <String, dynamic>{
      'priority': 'high',
      'isCustomNotification': true,
      'isShowLogo': false,
      'isShowCallback': false,
      'ringtonePath': 'system_ringtone_default',
      'backgroundColor': '#0955fa',
      'backgroundUrl': 'https://i.pravatar.cc/500',
      'actionColor': '#4CAF50'
    },
    'ios': <String, dynamic>{
      'iconName': 'CallKitLogo',
      'handleType': '',
      'supportsVideo': true,
      'maximumCallGroups': 2,
      'maximumCallsPerCallGroup': 1,
      'audioSessionMode': 'default',
      'audioSessionActive': true,
      'audioSessionPreferredSampleRate': 44100.0,
      'audioSessionPreferredIOBufferDuration': 0.005,
      'supportsDTMF': true,
      'supportsHolding': true,
      'supportsGrouping': false,
      'supportsUngrouping': false,
      'ringtonePath': 'system_ringtone_default'
    }
  };
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}