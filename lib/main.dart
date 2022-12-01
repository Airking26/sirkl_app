import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/common/language.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/firebase_options.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/profile/ui/profile_screen.dart';
import 'navigation/ui/navigation_screen.dart';

void main() async{
  final client = StreamChatClient(
    'v2s6zx9zjd9b',
    logLevel: Level.ALL,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  runApp(MyApp(client: client));


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
  late final FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    initFirebase();
    _homeController.putFCMToken(widget.client);
    super.initState();
  }

  initFirebase() async {
    await Firebase.initializeApp();
    _firebaseMessaging = FirebaseMessaging.instance;
    listen();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      showCallkitIncoming(message.data['uuid'] as String);
    });
  }

  listen(){
    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.name) {
        case CallEvent.ACTION_CALL_INCOMING:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_START:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_ACCEPT:
          checkAndNavigationCallingPage();
          break;
        case CallEvent.ACTION_CALL_DECLINE:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_ENDED:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_TIMEOUT:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_CALLBACK:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_HOLD:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_MUTE:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_DMTF:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_GROUP:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_AUDIO_SESSION:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
          print('Device Token FCM: $event');
          break;
      }
    });
  }

  getCurrentCall() async {
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        return calls[0];
      } else {
        return null;
      }
    }
  }

  checkAndNavigationCallingPage() async {
    var currentCall = await getCurrentCall();
    if (currentCall != null) {
      Get.to(() => const ProfileScreen());
    }
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