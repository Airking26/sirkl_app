import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sirkl/calls/service/calls_service.dart';
import 'package:sirkl/calls/ui/call_invite_sending_screen.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/call_creation_dto.dart';
import 'package:sirkl/common/model/call_dto.dart';
import 'package:sirkl/common/model/call_modification_dto.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/profile/service/profile_service.dart';
import 'package:sirkl/profile/ui/profile_screen.dart';

class CallsController extends GetxController{

  final _callService = CallService();
  final _homeService = HomeService();
  final _profileService = ProfileService();
  final box = GetStorage();
  final agoraEngine = (null as RtcEngine?).obs;
  var tokenAgoraRTC = "".obs;
  var userCalled = UserDTO().obs;
  var userJoinedCall = false.obs;
  var timerValue = 0.obs;

  Future<void> setupVoiceSDKEngine() async {
    await [Permission.microphone].request();

    agoraEngine.value = await RtcEngine.create("13d8acd177bf4c35a0d07bdd18c8e84e");
    await agoraEngine.value?.enableAudio();
    await agoraEngine.value?.leaveChannel();

    agoraEngine.value?.setEventHandler(
      RtcEngineEventHandler(
        error: (e){
          var kj = e;
        },
        joinChannelSuccess: (String x, int y, int elapsed) {
          Get.to(() => const CallInviteSendingScreen());
        },
        userJoined: (int remoteUid, int elapsed) {
          userJoinedCall.value = true;
        },
        userOffline: (int remoteUid, UserOfflineReason reason) {
          userJoinedCall.value = false;
        },
      ),
    );
  }

  leaveChannel() async{
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
    await createCall(CallCreationDto(updatedAt: DateTime.now(), called: user.id!, status: 0, channel: channel));
    await retrieveTokenAgoraRTC(channel, "publisher", "userAccount", myID);
    //await agoraEngine.value?.registerLocalUserAccount(tokenAgoraRTC.value, "63ad5f91c9b3f4001e421a51");
    await agoraEngine.value?.joinChannelWithUserAccount(tokenAgoraRTC.value, channel, myID);
  }

  join(String channelName, String id, String userCallingId) async {
    await getUserById(userCallingId);
    await retrieveTokenAgoraRTC(channelName, "audience", "userAccount", id);
    await agoraEngine.value?.joinChannelWithUserAccount(tokenAgoraRTC.value, channelName, id);
  }

  listenCall() {
    FlutterCallkitIncoming.onEvent.listen((event) async{
      switch (event!.name) {
        case CallEvent.ACTION_CALL_INCOMING:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_START:
          print('Device Token FCM: $event');
          break;
        case CallEvent.ACTION_CALL_ACCEPT:
          await join(event.body['id'], event.body['extra']['userCalled'], event.body['extra']['userCalling']);
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
    var request = await _callService.retrieveCalls(accessToken, offset);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _callService.retrieveCalls(accessToken, offset);
      if(request.isOk) return callDtoFromJson(json.encode(request.body));
    } else if(request.isOk) return callDtoFromJson(json.encode(request.body));
  }

  notifyCallEntering(String id, String channel) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _callService.notifyCallEntering(accessToken, id, channel);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _callService.notifyCallEntering(accessToken, id, channel);
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
    } else if(request.isOk) userCalled.value = userFromJson(json.encode(request.body));
  }

}

class Call {
  Call(this.number);
  String number;
  bool held = false;
  bool muted = false;
}