import 'dart:async';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:callkeep/callkeep.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CallsController extends GetxController{

  Rx<AgoraRtmClient?> agoraClient = (null as AgoraRtmClient?).obs;
  FlutterCallkeep callKeep = FlutterCallkeep();
  var callKeepInited = false.obs;

  final callSetup = <String, dynamic>{
    'ios': {
      'appName': 'CallKeepDemo',
    },
    'android': {
      'alertTitle': 'Permissions required',
      'alertDescription':
      'This application needs to access your phone accounts',
      'cancelButton': 'Cancel',
      'okButton': 'ok',
      // Required to get audio in background when using Android 11
      'foregroundService': {
        'channelId': 'com.company.my',
        'channelName': 'Foreground service for my app',
        'notificationTitle': 'My app is running on background',
        'notificationIcon': 'mipmap/ic_notification_launcher',
      },
    },
  };

  createCallKeep(BuildContext context){
    callKeep.setup(context, callSetup);
  }

  createClient(String id, String value) async {
    agoraClient.value = await AgoraRtmClient.createInstance("13d8acd177bf4c35a0d07bdd18c8e84e");
    var t = await agoraClient.value?.login(value, id);
    var g = '';    agoraClient.value!.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      var s = message;
    };
    agoraClient.value!.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        agoraClient.value!.logout();
      }
    };
    agoraClient.value!.onLocalInvitationReceivedByPeer = (AgoraRtmLocalInvitation invite) {
      var k = invite;
    };
    agoraClient.value!.onRemoteInvitationReceivedByPeer = (AgoraRtmRemoteInvitation invite) {
      var l = invite;
    };
  }

  inviteCall(String id, String channel) async {
    AgoraRtmLocalInvitation invitation = AgoraRtmLocalInvitation("6384ee96cb4bd6001e75b341", content: channel);
    await agoraClient.value!.sendLocalInvitation(invitation.toJson());
  }

  myBackgroundMessageHandler(RemoteMessage message) {
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
    if (!callKeepInited.value) {
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
      callKeepInited.value = true;
    }

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
  }

  Map<String, Call> calls = {};
  String newUUID() => Uuid().v4();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  iOS_Permission() async{
    var settings = await firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    print(settings);
  }

  void removeCall(String callUUID) {
      calls.remove(callUUID);
  }

  void setCallHeld(String callUUID, bool held) {
      calls[callUUID]!.held = held;
  }

  void setCallMuted(String callUUID, bool muted) {
      calls[callUUID]!.muted = muted;
  }

  Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
    final String callUUID = event.callUUID!;
    final String number = calls[callUUID]!.number;
    print('[answerCall] $callUUID, number: $number');
    Timer(const Duration(seconds: 1), () {
      print('[setCurrentCallActive] $callUUID, number: $number');
      callKeep.setCurrentCallActive(callUUID);
    });
  }

  Future<void> endCall(CallKeepPerformEndCallAction event) async {
    print('endCall: ${event.callUUID}');
    removeCall(event.callUUID!);
  }

  Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
    print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
  }

  Future<void> didReceiveStartCallAction(
      CallKeepDidReceiveStartCallAction event) async {
    if (event.handle == null) {
      // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
      return;
    }
    final String callUUID = event.callUUID ?? newUUID();
    calls[callUUID] = Call(event.handle!);
    print('[didReceiveStartCallAction] $callUUID, number: ${event.handle}');

    callKeep.startCall(callUUID, event.handle!, event.handle!);

    Timer(const Duration(seconds: 1), () {
      print('[setCurrentCallActive] $callUUID, number: ${event.handle}');
      callKeep.setCurrentCallActive(callUUID);
    });
  }

  Future<void> didPerformSetMutedCallAction(
      CallKeepDidPerformSetMutedCallAction event) async {
    final String number = calls[event.callUUID]!.number;
    print(
        '[didPerformSetMutedCallAction] ${event.callUUID}, number: $number (${event.muted})');

    setCallMuted(event.callUUID!, event.muted!);
  }

  Future<void> didToggleHoldCallAction(
      CallKeepDidToggleHoldAction event) async {
    final String number = calls[event.callUUID]!.number;
    print(
        '[didToggleHoldCallAction] ${event.callUUID}, number: $number (${event.hold})');

    setCallHeld(event.callUUID!, event.hold!);
  }

  Future<void> hangup(String callUUID) async {
    callKeep.endCall(callUUID);
    removeCall(callUUID);
  }

  Future<void> setOnHold(String callUUID, bool held) async {
    callKeep.setOnHold(callUUID, held);
    final String handle = calls[callUUID]!.number;
    print('[setOnHold: $held] $callUUID, number: $handle');
    setCallHeld(callUUID, held);
  }

  Future<void> setMutedCall(String callUUID, bool muted) async {
    callKeep.setMutedCall(callUUID, muted);
    final String handle = calls[callUUID]!.number;
    print('[setMutedCall: $muted] $callUUID, number: $handle');
    setCallMuted(callUUID, muted);
  }

  Future<void> updateDisplay(String callUUID) async {
    final String number = calls[callUUID]!.number;
    // Workaround because Android doesn't display well displayName, se we have to switch ...
    if (isIOS) {
      callKeep.updateDisplay(callUUID,
          displayName: 'New Name', handle: number);
    } else {
      callKeep.updateDisplay(callUUID,
          displayName: number, handle: 'New Name');
    }

    print('[updateDisplay: $number] $callUUID');
  }

  Future<void> displayIncomingCallDelayed(BuildContext context, String number) async {
    Timer(const Duration(seconds: 3), () {
      displayIncomingCall(context, number);
    });
  }

  Future<void> displayIncomingCall(BuildContext context, String number) async {
    final String callUUID = newUUID();
      calls[callUUID] = Call(number);
    print('Display incoming call now');
    final bool hasPhoneAccount = await callKeep.hasPhoneAccount();
    if (!hasPhoneAccount) {
      await callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
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
      });
    }

    print('[displayIncomingCall] $callUUID number: $number');
    callKeep.displayIncomingCall(callUUID, number,
        handleType: 'number', hasVideo: false);
  }

  void didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
    var callUUID = event.callUUID;
    var number = event.handle;
    print('[displayIncomingCall] $callUUID number: $number');
      calls[callUUID!] = Call(number!);
  }

  void onPushKitToken(CallKeepPushKitToken event) {
    print('[onPushKitToken] token => ${event.token}');
  }


}

class Call {
  Call(this.number);
  String number;
  bool held = false;
  bool muted = false;
}