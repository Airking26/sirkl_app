import 'dart:async';
import 'dart:convert';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/language.dart';
import 'package:sirkl/common/local_notification_initialize.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/profile/service/profile_service.dart';
import 'navigation/ui/navigation_screen.dart';
import 'package:sirkl/common/constants.dart' as con;

void main() async{
  final client = StreamChatClient("mhgk84t9jfnt");
  //StreamChatClient('v2s6zx9zjd9b', logLevel: Level.ALL);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
  final _chatController = Get.put(ChatsController());
  final _commonController = Get.put(CommonController());
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    _homeController.putFCMToken(context, widget.client);
    initFirebase();
    super.initState();
  }

  initFirebase() async {
    await LocalNotificationInitialize().initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if(message.data["type"] == "0" || message.data["type"] == "1"){
        LocalNotificationInitialize.showBigTextNotification(title: message.data["title"], body: message.data["body"], flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
      } else if(message.data['type'] == "message.new" && message.data['channel_id'] != _chatController.channel.value?.id){
        final client = StreamChat.of(context).client;
        final response = await client.getMessage(message.data['id']);
        final respChannel = await client.queryChannel("try", channelId: (message.data["cid"] as String).replaceFirst('try:', ''));
        if(respChannel.members!.length > 2) {
          LocalNotificationInitialize.showBigTextNotification(
              title: respChannel.channel!.name,
              body: "${response.message.user?.name} : ${response.message.text!}",
              flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
        } else {
          LocalNotificationInitialize.showBigTextNotification(
              title: "New message from ${response.message.user?.name}",
              body: response.message.text!,
              flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
        }
      }
      else {
        showCallkitIncoming(message.data['uuid'] as String);
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((event) async{
      if(event != null) {
        debugPrint("OnInitialMessage");
        final client = StreamChatClient("mhgk84t9jfnt");
        final box = GetStorage();
        var refreshToken = box.read(con.REFRESH_TOKEN);
        var requestToken = await HomeService().refreshToken(refreshToken);
        var refreshTokenDTO = refreshTokenDtoFromJson(
            json.encode(requestToken.body));
        var accessToken = refreshTokenDTO.accessToken!;
        var request = await ProfileService().retrieveTokenStreamChat(
            accessToken);
        var id = userFromJson(box.read(con.USER)).id;
        await client.connectUser(
            User(id: id!,), request.body!, connectWebSocket: false);
        final response = await client.queryChannel("try",
            channelId: (event.data["cid"] as String).replaceFirst('try:', ''));
        if (response.members!.length > 2) {
          Get.to(() => DetailedChatScreen(create: false, channelId: (event.data["cid"] as String).replaceFirst('try:', '')));
        } else {
          final user = response.members!.where((element) =>
          element.user!.id != event.data["receiver_id"]).toList()[0];
          await _commonController.getUserById(user.user!.id);
          Get.to(() => const DetailedChatScreen(create: true,));
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) async{
      debugPrint("OnMessageOpenedApp");
      final response = await StreamChat.of(context).client.queryChannel("try", channelId: (event.data["cid"] as String).replaceFirst('try:', ''));
      if(response.members!.length > 2){
        Get.to(() => DetailedChatScreen(create: false, channelId: (event.data["cid"] as String).replaceFirst('try:', '')));
      } else {
        final user = response.members!.where((element) =>
        element.user!.id != event.data["receiver_id"]).toList()[0];
        await _commonController.getUserById(user.user!.id);
        Get.to(() => const DetailedChatScreen(create: true,));
      }
    });
    _callController.listenCall();
  }


  @override
  Widget build(BuildContext context) {
    return const NavigationScreen();
  }

}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await LocalNotificationInitialize().initialize(flutterLocalNotificationsPlugin);
  if(message.data["type"] == "0" || message.data["type"] == "1"){
    LocalNotificationInitialize.showBigTextNotification(title: message.data["title"], body: message.data["body"], flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
  }
  /*else if(message.data['type'] == "message.new"){
    final client = StreamChatClient("mhgk84t9jfnt");
    final box = GetStorage();
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var requestToken = await HomeService().refreshToken(refreshToken);
    var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
    var accessToken = refreshTokenDTO.accessToken!;
    var request = await ProfileService().retrieveTokenStreamChat(accessToken);
    var id = userFromJson(box.read(con.USER)).id;
    await client.connectUser(User(id: id!,), request.body!, connectWebSocket: false);
    final response = await client.getMessage(message.data['id']);
    final respChannel = await client.queryChannel("try", channelId: (message.data["cid"] as String).replaceFirst('try:', ''));
    if(respChannel.members!.length > 2) {
      LocalNotificationInitialize.showBigTextNotification(
          title: respChannel.channel!.name,
          body: "${response.message.user?.name} : ${response.message.text!}",
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    } else {
      LocalNotificationInitialize.showBigTextNotification(
          title: "New message from ${response.message.user?.name}",
          body: response.message.text!,
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    }
  }*/
  else if(message.data["uuid"] != null) {
    showCallkitIncoming(message.data['uuid'] as String);
  }
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