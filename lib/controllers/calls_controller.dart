import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/repo/calls_repo.dart';

import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/call_creation_dto.dart';
import 'package:sirkl/common/model/call_dto.dart';
import 'package:sirkl/common/model/call_modification_dto.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/repo/home_repo.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/repo/profile_repo.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../common/save_pref_keys.dart';
import '../views/calls/call_invite_sending_screen.dart';


class CallsController extends GetxController{

  final box = GetStorage();

  NavigationController get _navigationController => Get.find<NavigationController>();
  Rx<PagingController<int, CallDto>> pagingController = PagingController<int, CallDto>(firstPageKey: 0).obs;

  late RtcEngine? rtcEngine;
  late String? tokenAgoraRTC;
  late Timer? timerRing;
  late String? currentCallID;

  var callList = (null as List<CallDto>?).obs;

  var userCalled = UserDTO().obs;
  var timer = StopWatchTimer().obs;

  var callQuery = "".obs;
  var pageKey = 0.obs;

  var isFromConv = false.obs;
  var isCallMuted = false.obs;
  var isCallOnSpeaker = false.obs;
  var isSearchIsActive = false.obs;
  var userJoinedCall = false.obs;

  Future<void> setupVoiceSDKEngine(BuildContext context) async {

    rtcEngine = await RtcEngine.create("13d8acd177bf4c35a0d07bdd18c8e84e");
    await rtcEngine?.enableAudio();
    await rtcEngine?.leaveChannel();


    rtcEngine?.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String x, int y, int elapsed) {
          playRingback(1);
          pushNewScreen(context, screen: const CallInviteSendingScreen(), withNavBar: false).then((value) {
            pageKey.value = 0;
            pagingController.value.refresh();
            _navigationController.hideNavBar.value = isFromConv.value;
            isFromConv.value = false;
          });
        },
        userJoined: (int remoteUid, int elapsed) {
          playRingback(50);
          timer.value = StopWatchTimer();
          timer.value.onStartTimer();
          userJoinedCall.value = true;
        },
        userOffline: (int remoteUid, UserOfflineReason reason) async {
          await leaveChannel();
        },
      ),
    );
  }

  void playRingback(int soundToPlay) {
       if(Platform.isAndroid) {
      FlutterBeep.playSysSound(soundToPlay == 50 ? 50 : 35);
    } else {
      FlutterBeep.playSysSound(soundToPlay == 50 ? 50 : 37).then((value) {
          if(soundToPlay != 50) {
            timerRing = Timer.periodic(const Duration(seconds: 4), (timer) {
              FlutterBeep.playSysSound(37);
            });
          } else {
            timerRing?.cancel();
          }
      });

    }
  }

  leaveChannel() async{
    userJoinedCall.value = false;
    await rtcEngine?.leaveChannel();
    Get.back();
  }

  retrieveTokenAgoraRTC(String channel, String role, String tokenType, String id) async{
    tokenAgoraRTC = await ProfileRepo.retrieveTokenAgoraRTC(channel, role, tokenType, id);
  }

  inviteCall(UserDTO user, String channel, String myID) async {
    userCalled.value = user;
    currentCallID = channel;
    await createCall(CallCreationDto(updatedAt: DateTime.now(), called: user.id!, status: 0, channel: channel));
    await retrieveTokenAgoraRTC(channel, "publisher", "userAccount", myID);
    await rtcEngine?.joinChannelWithUserAccount(tokenAgoraRTC, channel, myID);
  }

  join(String channelName, String id, String userCallingId) async {
    await getUserById(userCallingId);
    await retrieveTokenAgoraRTC(channelName, "audience", "userAccount", id);
    await rtcEngine?.joinChannelWithUserAccount(tokenAgoraRTC, channelName, id);
  }

  listenCall() {
    FlutterCallkitIncoming.onEvent.listen((event) async{
      switch (event!.event) {
        case Event.actionCallIncoming:
          currentCallID = event.body['id'];
          break;
        case Event.actionCallStart:
          break;
        case Event.actionCallAccept:
          playRingback(50);
          await join(event.body['extra']["channel"] ?? event.body['id'], event.body['extra']['userCalled'], event.body['extra']['userCalling']);
          break;
        case Event.actionCallDecline:
          playRingback(50);
          await FlutterCallkitIncoming.endAllCalls();
          await endCall(event.body["extra"]["userCalling"], event.body["id"]);
          break;
        case Event.actionCallEnded:
          playRingback(50);
          await FlutterCallkitIncoming.endAllCalls();
          break;
        case Event.actionCallTimeout:
          playRingback(50);
          await updateCall(CallModificationDto(id: event.body["extra"]["callId"], status: 2, updatedAt: DateTime.now()));
          break;
        case Event.actionCallCallback:
          print('Device Token FCM: $event');
          break;
        case Event.actionCallToggleHold:
          print('Device Token FCM: $event');
          break;
        case Event.actionCallToggleMute:
          print('Device Token FCM: $event');
          break;
        case Event.actionCallToggleDmtf:
          print('Device Token FCM: $event');
          break;
        case Event.actionCallToggleGroup:
          print('Device Token FCM: $event');
          break;
        case Event.actionCallToggleAudioSession:
          print('Device Token FCM: $event');
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          print('Device Token FCM: $event');
          break;
        case Event.actionCallCustom:
          print('Device Token FCM: $event');
          break;
      }
    });
  }

  Future<void> createCall(CallCreationDto callCreationDto) async {

     await CallRepo.createCall(callCreationDto);

  }

  updateCall(CallModificationDto callModificationDto) async {
  
    await CallRepo.updateCall(callModificationDto);

  }

  Future<List<CallDto>> retrieveCalls(String offset) async{

  
       List<CallDto> calls = await CallRepo.retrieveCalls(offset);
      callList.value ??= [];
      callList.value!.addAll(calls);
      return calls;

  }

  Future<List<UserDTO>> retrieveUsers(String substring, int offset) async{

    try{
      return await CallRepo.searchUser(substring, offset.toString());
     
    } on Error{

    }
 
       return [];
  }

  Future<void> endCall(String id, String channel) async{

   await CallRepo.endCall( id, channel);

  }

  missedCallNotification(String id) async{
    await CallRepo.missedCallNotification(id);
  }

  getUserById(String id) async {
 
    userCalled.value = await ProfileRepo.getUserByID(id);

  }

  Future<List<CallDto>> searchInCalls(String search) async{

    try {
       return await CallRepo.searchCalls(search);
    } catch(err) {
      return [];
    }

  }

}

class Call {
  Call(this.number);
  String number;
  bool held = false;
  bool muted = false;
}