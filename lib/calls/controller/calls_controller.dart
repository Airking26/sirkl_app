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
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/service/profile_service.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';


class CallsController extends GetxController{

  final _callService = CallService();
  final _homeService = HomeService();
  final _profileService = ProfileService();
  final _navigationController = Get.put(NavigationController());
  final box = GetStorage();
  final agoraEngine = (null as RtcEngine?).obs;
  var tokenAgoraRTC = "".obs;
  var callList = (null as List<CallDto>?).obs;
  var userCalled = UserDTO().obs;
  var userJoinedCall = false.obs;
  var timer = StopWatchTimer().obs;
  var currentCallId = "".obs;
  var isCallMuted = false.obs;
  var isCallOnSpeaker = false.obs;
  var isSearchIsActive = false.obs;
  var callQuery = "".obs;
  Rx<PagingController<int, CallDto>> pagingController = PagingController<int, CallDto>(firstPageKey: 0).obs;
  var pageKey = 0.obs;
  var isFromConv = false.obs;
  late Timer timerRing;

  Future<void> setupVoiceSDKEngine(BuildContext context) async {
    await [Permission.microphone].request();

    agoraEngine.value = await RtcEngine.create("13d8acd177bf4c35a0d07bdd18c8e84e");
    await agoraEngine.value?.enableAudio();
    await agoraEngine.value?.leaveChannel();


    agoraEngine.value?.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String x, int y, int elapsed) {
          _navigationController.hideNavBar.value = true;
          playRingback(1);
          pushNewScreen(context, screen: const CallInviteSendingScreen()).then((value) {
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
            timerRing.cancel();
          }
      });

    }
  }

  leaveChannel() async{
    userJoinedCall.value = false;
    await agoraEngine.value?.leaveChannel();
    Get.back();
  }

  retrieveTokenAgoraRTC(String channel, String role, String tokenType, String id) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.retrieveTokenAgoraRTC(accessToken, channel, role, tokenType, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.retrieveTokenAgoraRTC(accessToken, channel, role, tokenType, id);
      if(request.isOk) tokenAgoraRTC.value = request.body!;
    } else if(request.isOk) {
      tokenAgoraRTC.value = request.body!;
    }
  }

  inviteCall(UserDTO user, String channel, String myID) async {
    userCalled.value = user;
    currentCallId.value = channel;
    await createCall(CallCreationDto(updatedAt: DateTime.now(), called: user.id!, status: 0, channel: channel));
    await retrieveTokenAgoraRTC(channel, "publisher", "userAccount", myID);
    await agoraEngine.value?.joinChannelWithUserAccount(tokenAgoraRTC.value, channel, myID);
  }

  join(String channelName, String id, String userCallingId) async {
    await getUserById(userCallingId);
    await retrieveTokenAgoraRTC(channelName, "audience", "userAccount", id);
    await agoraEngine.value?.joinChannelWithUserAccount(tokenAgoraRTC.value, channelName, id);
  }

  listenCall() {
    FlutterCallkitIncoming.onEvent.listen((event) async{
      switch (event!.event) {
        case Event.ACTION_CALL_INCOMING:
          currentCallId.value = event.body['id'];
          print('Device Token FCM: $event');
          break;
        case Event.ACTION_CALL_START:
          print('Device Token FCM: $event');
          break;
        case Event.ACTION_CALL_ACCEPT:
          playRingback(50);
          await join(event.body['extra']["channel"] ?? event.body['id'], event.body['extra']['userCalled'], event.body['extra']['userCalling']);
          break;
        case Event.ACTION_CALL_DECLINE:
          playRingback(50);
          await FlutterCallkitIncoming.endAllCalls();
          await endCall(event.body["extra"]["userCalling"], event.body["id"]);
          break;
        case Event.ACTION_CALL_ENDED:
          playRingback(50);
          await FlutterCallkitIncoming.endAllCalls();
          print('Device Token FCM: $event');
          break;
        case Event.ACTION_CALL_TIMEOUT:
          playRingback(50);
          await updateCall(CallModificationDto(id: event.body["extra"]["callId"], status: 2, updatedAt: DateTime.now()));
          break;
        case Event.ACTION_CALL_CALLBACK:
          print('Device Token FCM: $event');
          break;
        case Event.ACTION_CALL_TOGGLE_HOLD:
          print('Device Token FCM: $event');
          break;
        case Event.ACTION_CALL_TOGGLE_MUTE:
          print('Device Token FCM: $event');
          break;
        case Event.ACTION_CALL_TOGGLE_DMTF:
          print('Device Token FCM: $event');
          break;
        case Event.ACTION_CALL_TOGGLE_GROUP:
          print('Device Token FCM: $event');
          break;
        case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
          print('Device Token FCM: $event');
          break;
        case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
          print('Device Token FCM: $event');
          break;
      }
    });
  }

  createCall(CallCreationDto callCreationDto) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _callService.createCall(accessToken, callCreationDtoToJson(callCreationDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _callService.createCall(accessToken, callCreationDtoToJson(callCreationDto));
    }
  }

  updateCall(CallModificationDto callModificationDto) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _callService.updateCall(accessToken, callModificationDtoToJson(callModificationDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _callService.updateCall(accessToken, callModificationDtoToJson(callModificationDto));
    }
  }

  retrieveCalls(String offset) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request;
    try{
      request = await _callService.retrieveCalls(accessToken, offset);
    } on Error{
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _callService.retrieveCalls(accessToken, offset);
    }
    if(request.isOk) {
      callList.value = callDtoFromJson(json.encode(request.body));
      return callDtoFromJson(json.encode(request.body));
    }
  }

  Future<List<UserDTO>> retrieveUsers(String substring, int offset) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request;
    try{
      request = await _callService.searchUser(accessToken, substring, offset.toString());
    } on Error{
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _callService.searchUser(accessToken, substring, offset.toString());
    }
    if(request.isOk) {
      return request.body!.map<UserDTO>((user) => userFromJson(json.encode(user))).toList();
    } else {
      return [];
    }
  }

  endCall(String id, String channel) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _callService.endCall(accessToken, id, channel);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _callService.endCall(accessToken, id, channel);
    }
  }

  missedCallNotification(String id) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _callService.missedCallNotification(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _callService.missedCallNotification(accessToken, id);
    }
  }

  getUserById(String id) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.getUserByID(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.getUserByID(accessToken, id);
      if(request.isOk) userCalled.value = userFromJson(json.encode(request.body));
    } else if(request.isOk) {
      userCalled.value = userFromJson(json.encode(request.body));
    }
  }

  Future<List<CallDto>> searchInCalls(String search) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _callService.searchCalls(accessToken, search);
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
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