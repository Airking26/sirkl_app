import 'dart:async';
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
import 'package:sirkl/models/call_creation_dto.dart';
import 'package:sirkl/models/call_dto.dart';
import 'package:sirkl/models/call_modification_dto.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/config/s_config.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/repo/calls_repo.dart';
import 'package:sirkl/repo/profile_repo.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../views/calls/call_invite_sending_screen.dart';

class CallController extends GetxController {
  final box = GetStorage();

  NavigationController get _navigationController =>
      Get.find<NavigationController>();
  Rx<PagingController<int, CallDto>> pagingController =
      PagingController<int, CallDto>(firstPageKey: 0).obs;

  late RtcEngine? rtcEngine;
  late String? tokenAgoraRTC;
  late Timer? timerRing;
  late String? currentCallID;

  var callHistoric = (null as List<CallDto>?).obs;

  var userCalled = UserDTO().obs;
  var timer = StopWatchTimer().obs;

  var queryCall = "".obs;
  var pageKey = 0.obs;

  var isFromConv = false.obs;
  var isCallMuted = false.obs;
  var isCallOnSpeaker = false.obs;
  var isSearchIsActive = false.obs;
  var userJoinedCall = false.obs;

  /// Function to initialize and setup Agora
  Future<void> setupVoiceSDKEngine(BuildContext context) async {
    rtcEngine = await RtcEngine.create(SConfig.agoraId);
    await rtcEngine?.enableAudio();
    await rtcEngine?.leaveChannel();

    rtcEngine?.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String x, int y, int elapsed) {
          [Permission.microphone].request();
          playRingtone(1);
          pushNewScreen(context,
                  screen: const CallInviteSendingScreen(), withNavBar: false)
              .then((value) {
            pageKey.value = 0;
            pagingController.value.refresh();
            _navigationController.hideNavBar.value = isFromConv.value;
            isFromConv.value = false;
          });
        },
        userJoined: (int remoteUid, int elapsed) {
          [Permission.microphone].request();
          playRingtone(50);
          timer.value = StopWatchTimer();
          timer.value.onStartTimer();
          userJoinedCall.value = true;
        },
        userOffline: (int remoteUid, UserOfflineReason reason) async {
          await leaveCallChanel();
        },
      ),
    );
  }

  /// Function to invite user to join a call
  Future<void> inviteToJoinCall(
      UserDTO user, String channel, String myID) async {
    userCalled.value = user;
    currentCallID = channel;
    await CallRepo.createCall(CallCreationDto(
        updatedAt: DateTime.now(),
        called: user.id!,
        status: 0,
        channel: channel));
    await _retrieveTokenAgoraRTC(channel, "publisher", "userAccount", myID);
    await rtcEngine?.joinChannelWithUserAccount(tokenAgoraRTC, channel, myID);
  }

  /// Function for user to join a call
  Future<void> joinCall(
      String channelName, String id, String userCallingId) async {
    userCalled.value = await ProfileRepo.getUserByID(userCallingId);
    await _retrieveTokenAgoraRTC(channelName, "audience", "userAccount", id);
    await rtcEngine?.joinChannelWithUserAccount(tokenAgoraRTC, channelName, id);
  }

  /// Private function to assign Agora token
  Future<void> _retrieveTokenAgoraRTC(
      String channel, String role, String tokenType, String id) async {
    tokenAgoraRTC =
        await ProfileRepo.retrieveTokenAgoraRTC(channel, role, tokenType, id);
  }

  /// Function to leave a channel (call channel)
  Future<void> leaveCallChanel() async {
    userJoinedCall.value = false;
    await rtcEngine?.leaveChannel();
    Get.back();
  }

  /// Function to end a call
  Future<void> endCall(String id, String channel) async =>
      await CallRepo.endCall(id, channel);

  /// Function to notify user receiving call : Missed call
  Future<void> missedCallNotification(String id) async {
    await CallRepo.missedCallNotification(id);
  }

  /// Function to retrieve call historic
  Future<List<CallDto>> retrieveCallHistoric(String offset) async {
    List<CallDto> calls = await CallRepo.retrieveCalls(offset);
    callHistoric.value ??= [];
    callHistoric.value!.addAll(calls);
    return calls;
  }

  /// Function to search a specific call in call historic
  Future<List<CallDto>> searchInCallHistoric(String search) async {
    try {
      return await CallRepo.searchCalls(search);
    } catch (err) {
      return [];
    }
  }

  /// Function to search user
  // TODO : Remove from here and place into a searchController
  Future<List<UserDTO>> searchUser(String substring, int offset) async {
    try {
      return await CallRepo.searchUser(substring, offset.toString());
    } on Error {}

    return [];
  }

  /// Function for listening call events
  void listenCallEvents() {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:
          currentCallID = event.body['id'];
          break;
        case Event.actionCallStart:
          break;
        case Event.actionCallAccept:
          playRingtone(50);
          await joinCall(
              event.body['extra']["channel"] ?? event.body['id'],
              event.body['extra']['userCalled'],
              event.body['extra']['userCalling']);
          break;
        case Event.actionCallDecline:
          playRingtone(50);
          await FlutterCallkitIncoming.endAllCalls();
          await endCall(event.body["extra"]["userCalling"], event.body["id"]);
          break;
        case Event.actionCallEnded:
          playRingtone(50);
          await FlutterCallkitIncoming.endAllCalls();
          break;
        case Event.actionCallTimeout:
          playRingtone(50);
          await CallRepo.updateCall(CallModificationDto(
              id: event.body["extra"]["callId"],
              status: 2,
              updatedAt: DateTime.now()));
          break;
        case Event.actionCallCallback:
          debugPrint('Device Token FCM: $event');
          break;
        case Event.actionCallToggleHold:
          debugPrint('Device Token FCM: $event');
          break;
        case Event.actionCallToggleMute:
          debugPrint('Device Token FCM: $event');
          break;
        case Event.actionCallToggleDmtf:
          debugPrint('Device Token FCM: $event');
          break;
        case Event.actionCallToggleGroup:
          debugPrint('Device Token FCM: $event');
          break;
        case Event.actionCallToggleAudioSession:
          debugPrint('Device Token FCM: $event');
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          debugPrint('Device Token FCM: $event');
          break;
        case Event.actionCallCustom:
          debugPrint('Device Token FCM: $event');
          break;
      }
    });
  }

  /// Function to play ringtone while waiting for action
  void playRingtone(int soundToPlay) {
    if (Platform.isAndroid) {
      FlutterBeep.playSysSound(soundToPlay == 50 ? 50 : 35);
    } else {
      FlutterBeep.playSysSound(soundToPlay == 50 ? 50 : 37).then((value) {
        if (soundToPlay != 50) {
          timerRing = Timer.periodic(const Duration(seconds: 4), (timer) {
            FlutterBeep.playSysSound(37);
          });
        } else {
          timerRing?.cancel();
        }
      });
    }
  }
}
