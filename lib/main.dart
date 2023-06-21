// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart' as entities;
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/common/model/notification_register_dto.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/language.dart';
import 'package:sirkl/common/local_notification_initialize.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/home/utils/analyticService.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/service/profile_service.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:stream_chat_persistence/stream_chat_persistence.dart';
import 'chats/ui/settings_group_screen.dart';
import 'global_getx/dependency_manager.dart';
import 'navigation/ui/navigation_screen.dart';
import 'package:sirkl/common/constants.dart' as con;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("OnDebugSirkl : Background Handler");
  await GetStorage().initStorage;
  var notificationActive = GetStorage().read(con.NOTIFICATION_ACTIVE) ?? true;
  if(notificationActive) {
    debugPrint("ENTERING NOTIFICATION ACTIVE");
    if (message.data['type'] == "2") {
      await FlutterCallkitIncoming.endAllCalls();
    }  else if (message.data['type'] == "4") {
      try {
        var notificationSaved = GetStorage().read(con.notificationSaved) ?? [];
        (notificationSaved as List<dynamic>).add(message.data["body"]);
        await GetStorage().write(con.notificationSaved, notificationSaved);
      } on Error {
        throw Error();
      }
    } else if (message.data['type'] == "8") {
      debugPrint("ENTERING 8 MODE");
      showCallNotification(message.data);
    }
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final chatPersistentClient = StreamChatPersistenceClient(
    logLevel: Level.INFO,
    connectionMode: ConnectionMode.background,
  );
  final client = StreamChatClient("mhgk84t9jfnt", logLevel: Level.WARNING)
    ..chatPersistenceClient = chatPersistentClient;
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.subscribeToTopic("all");
  await GetStorage.init();
  AnalyticService().getAnalyticObserver();
  runApp(MyApp(client: client,));
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
        return StreamChat(client: client, child: MediaQuery(data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0), child: child!),);
      },
      darkTheme: ThemeData(brightness: Brightness.dark, dividerColor: Colors.transparent),
      themeMode: ThemeMode.system,
      theme: ThemeData(brightness: Brightness.light, dividerColor: Colors.transparent),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      initialBinding: GlobalDependencyManager(),
      
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{

  final _homeController = Get.put(HomeController());
  final _callController = Get.put(CallsController());
  final _chatController = Get.put(ChatsController());
  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  @override
  void initState() {
    _homeController.connectUser(StreamChat.of(context).client);
    _homeController.putFCMToken(context, StreamChat.of(context).client, true);
    initFirebase();
    _callController.setupVoiceSDKEngine(context);
    getCurrentCall();
    super.initState();
  }


  getCurrentCall() async {
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        if(calls[0]['id'] != null && calls[0]['id'] != '') {
          await _callController.join(
              calls[0]['extra']['channel'], calls[0]["extra"]["userCalled"],
              calls[0]['extra']['userCalling']);
        }
        return calls[0];
      } else {
        return null;
      }
    }
  }

  initFirebase() async {
    await LocalNotificationInitialize().initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint("onMessage: $message");
        if (_homeController.notificationActive.value) {
          if (message.data["type"] == "0" || message.data["type"] == "1" || message.data['type'] == "5" || message.data['type'] == "6" || message.data['type'] == "7") {
            LocalNotificationInitialize.showBigTextNotification(
                title: message.data["title"],
                body: message.data["body"],
                flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
          } else if (message.data['type'] == "2") {
            await FlutterCallkitIncoming.endAllCalls();
            await _callController.leaveChannel();
          } else if (message.data['type'] == "3") {
            await FlutterCallkitIncoming.endAllCalls();
            LocalNotificationInitialize.showBigTextNotification(
                title: message.data["title"],
                body: message.data["body"],
                flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
          } else if (message.data['type'] == "4") {
            LocalNotificationInitialize.showBigTextNotification(
                title: message.data["title"],
                body: message.data["body"],
                flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
            await _homeController.registerNotification(
                NotificationRegisterDto(message: message.data["body"]));
          }
          else if (message.data['type'] == "message.new" &&
              message.data['channel_id'] != _chatController.channel.value?.id) {
            final client = StreamChat
                .of(context)
                .client;
            final response = await client.getMessage(message.data['id']);
            final respChannel = await client.queryChannel("try",
                channelId: (message.data["cid"] as String).replaceFirst(
                    'try:', ''));
            if (respChannel.members!.length > 2) {
              LocalNotificationInitialize.showBigTextNotification(
                  title: respChannel.channel!.name,
                  body: "${response.message.user?.name} : ${response.message
                      .text!}",
                  flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
            } else {
              LocalNotificationInitialize.showBigTextNotification(
                  title: "New message from ${response.message.user?.name}",
                  body: response.message.text!,
                  flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
            }
          }
          else {
            if(message.data['type'] == "8" ) showCallNotification(message.data);
          }
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((event) async {
        debugPrint("OnMessageOpenedApp");
        if (event.data["cid"] != null) {
          final response = await StreamChat
              .of(context)
              .client
              .queryChannel("try",
              channelId: (event.data["cid"] as String).replaceFirst(
                  'try:', ''));
          if (response.members!.length > 2) {
            _navigationController.hideNavBar.value = true;
            pushNewScreen(context, screen: DetailedChatScreen(create: false,
                channelId: (event.data["cid"] as String).replaceFirst(
                    'try:', ''))).then((value) =>
            _navigationController.hideNavBar.value = false);
          } else {
            final user = response.members!.where((element) =>
            element.user!.id != event.data["receiver_id"]).toList()[0];
            await _commonController.getUserById(user.user!.id);
            _navigationController.hideNavBar.value = true;
            pushNewScreen(
                context, screen: const DetailedChatScreen(create: true)).then((
                value) => _navigationController.hideNavBar.value = false);
          }
        }
      });

      FirebaseMessaging.instance.getInitialMessage().then((event) async {
        debugPrint("OnDebugSirkl : Initial Message");
        if (event != null) {
          debugPrint("Event not null");
          if (event.data['cid'] != null) {
            debugPrint("OnDebugSirkl : CID not null");
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
                channelId: (event.data["cid"] as String).replaceFirst(
                    'try:', ''));
            if (response.members!.length > 2) {
              _navigationController.hideNavBar.value = true;
              pushNewScreen(context, screen: DetailedChatScreen(create: false,
                  channelId: (event.data["cid"] as String).replaceFirst(
                      'try:', ''))).then((value) =>
              _navigationController.hideNavBar.value = false);
            } else {
              final user = response.members!.where((element) =>
              element.user!.id != event.data["receiver_id"]).toList()[0];
              await _commonController.getUserById(user.user!.id);
              _navigationController.hideNavBar.value = true;
              pushNewScreen(
                  context, screen: const DetailedChatScreen(create: true))
                  .then((value) =>
              _navigationController.hideNavBar.value = false);
            }
          }
        }
        else {
          debugPrint("OnDebugSirkl : Event is null");
        }
      });

    FirebaseDynamicLinks.instance.onLink.listen((event) async{
      final Uri uri = event.link;
      final queryParams = uri.queryParameters;
      if(queryParams.isNotEmpty){
        var path = event.link.path;
        var id = queryParams["id"];
        if(path == "/profileShared") {
          await _commonController.getUserById(id!);
          pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: false));
        } else if(path == "/joinGroup"){
            var stream = StreamChat.of(context).client.queryChannels(filter: Filter.equal("id", id!));
            var channels = await stream.first;
            var channel = channels.first;
            _chatController.channel.value = channel;
            if(channel.membership == null && channel.extraData["isConv"] != null && channel.extraData["isConv"] == false){
              pushNewScreen(context, screen: const SettingsGroupScreen());
            } else {
              pushNewScreen(context, screen: StreamChannel(channel: channel, child: const ChannelPage()));
            }
        }
      }
    }).onError((error){
    });

    FirebaseDynamicLinks.instance.getInitialLink().then((event) async {
      if(event != null) {
        final Uri uri = event.link;
        final queryParams = uri.queryParameters;
        if (queryParams.isNotEmpty) {
          var path = event.link.path;
          var id = queryParams["id"];
          if (path == "/profileShared") {
            await _commonController.getUserById(id!);
            pushNewScreen(context,
                screen: const ProfileElseScreen(fromConversation: false));
          } else if (path == "/joinGroup") {
            _homeController.retrieveAccessToken();
            try {
              await _homeController.connectUser(StreamChat.of(context).client);}
            catch (e) {
              var stream = StreamChat.of(context).client.queryChannels(
                  filter: Filter.equal("id", id!));
              var channels = await stream.first;
              var channel = channels.first;
              _chatController.channel.value = channel;
              if (channel.membership == null &&
                  channel.extraData["isConv"] != null &&
                  channel.extraData["isConv"] == false) {
                pushNewScreen(context, screen: const SettingsGroupScreen());
              } else {
                pushNewScreen(context, screen: StreamChannel(
                    channel: channel, child: const ChannelPage()));
              }
            }
          }
        }
      }
    });
      _callController.listenCall();
  }

  @override
  Widget build(BuildContext context) {
    return const NavigationScreen();
  }

}

Future<void> showCallNotification(Map<String, dynamic> data) async {
  var params = entities.CallKitParams(
      id: data['uuid'],
      nameCaller : data["title"],
      appName: 'Sirkl',
    avatar: data["pic"] ?? 'https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png',
    handle: data["body"],
    type: 0,
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const entities.NotificationParams(showNotification: false),
    extra: <String, dynamic>{'userCalling': data["caller_id"], "userCalled": data['called_id'], "callId": data["call_id"], "channel": data["channel"]},
    android: const entities.AndroidParams(
      isCustomNotification: true,
      isCustomSmallExNotification: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#102437',
      actionColor: '#4CAF50'
    ),
    ios: const entities.IOSParams(
      iconName: 'CallKitLogo',
      handleType: '',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default'
    )
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);

}