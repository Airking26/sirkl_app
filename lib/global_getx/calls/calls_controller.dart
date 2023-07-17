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
import 'package:sirkl/calls/service/calls_service.dart';
import 'package:sirkl/calls/ui/call_invite_sending_screen.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/call_creation_dto.dart';
import 'package:sirkl/common/model/call_dto.dart';
import 'package:sirkl/common/model/call_modification_dto.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/repo/home_repo.dart';
import 'package:sirkl/global_getx/navigation/navigation_controller.dart';
import 'package:sirkl/repo/profile_repo.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../constants/save_pref_keys.dart';


class CallsController extends GetxController{

  final _callService = CallService();
  //final _homeService = HomeRepo();

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
    await [Permission.microphone].request();

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

  createCall(CallCreationDto callCreationDto) async {
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);
    var request = await _callService.createCall(accessToken, callCreationDtoToJson(callCreationDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(SharedPref.ACCESS_TOKEN, accessToken);
      request = await _callService.createCall(accessToken, callCreationDtoToJson(callCreationDto));
    }
  }

  updateCall(CallModificationDto callModificationDto) async {
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);
    var request = await _callService.updateCall(accessToken, callModificationDtoToJson(callModificationDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(SharedPref.ACCESS_TOKEN, accessToken);
      request = await _callService.updateCall(accessToken, callModificationDtoToJson(callModificationDto));
    }
  }

  retrieveCalls(String offset) async{
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);
    var request;
    try{
      request = await _callService.retrieveCalls(accessToken, offset);
    } on Error{
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(SharedPref.ACCESS_TOKEN, accessToken);
      request = await _callService.retrieveCalls(accessToken, offset);
    }
    if(request.isOk) {
      callList.value == null ? callList.value = callDtoFromJson(json.encode(request.body)) : callList.value?.addAll(callDtoFromJson(json.encode(request.body)));
      return callDtoFromJson(json.encode(request.body));
    }
  }

  Future<List<UserDTO>> retrieveUsers(String substring, int offset) async{
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);
    var request;
    try{
      request = await _callService.searchUser(accessToken, substring, offset.toString());
    } on Error{
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(SharedPref.ACCESS_TOKEN, accessToken);
      request = await _callService.searchUser(accessToken, substring, offset.toString());
    }
    if(request.isOk) {
      return request.body!.map<UserDTO>((user) => userFromJson(json.encode(user))).toList();
    } else {
      return [];
    }
  }

  endCall(String id, String channel) async{
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);
    var request = await _callService.endCall(accessToken, id, channel);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(SharedPref.ACCESS_TOKEN, accessToken);
      request = await _callService.endCall(accessToken, id, channel);
    }
  }

  missedCallNotification(String id) async{
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);
    var request = await _callService.missedCallNotification(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(SharedPref.ACCESS_TOKEN, accessToken);
      request = await _callService.missedCallNotification(accessToken, id);
    }
  }

  getUserById(String id) async {
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);
    var request = await _profileService.getUserByID(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(SharedPref.ACCESS_TOKEN, accessToken);
      request = await _profileService.getUserByID(accessToken, id);
      if(request.isOk) userCalled.value = userFromJson(json.encode(request.body));
    } else if(request.isOk) {
      userCalled.value = userFromJson(json.encode(request.body));
    }
  }

  Future<List<CallDto>> searchInCalls(String search) async{
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);
    var req = await _callService.searchCalls(accessToken, search);
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(SharedPref.ACCESS_TOKEN, accessToken);
      req = await _callService.searchCalls(accessToken, search);
      if(req.isOk) {
        return callDtoFromJson(json.encode(req.body));
      } else {
        return [];
      }
    } else if(req.isOk){
      return callDtoFromJson(json.encode(req.body));
    } else {
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