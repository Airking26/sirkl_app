import 'dart:convert';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/calls/service/calls_service.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/profile/service/profile_service.dart';
import 'package:sirkl/profile/ui/profile_screen.dart';

class CallsController extends GetxController{

  final _callService = CallService();
  final _homeService = HomeService();
  final _profileService = ProfileService();
  final box = GetStorage();

  Future<AgoraRtmClient> initClient() async{
    return await AgoraRtmClient.createInstance("13d8acd177bf4c35a0d07bdd18c8e84e");
  }

  createClient(AgoraRtmClient agoraClient) async {
    agoraClient.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      var s = message;
    };
    agoraClient.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        agoraClient.logout();
      }
    };
    agoraClient.onLocalInvitationReceivedByPeer = (AgoraRtmLocalInvitation invite) async{
      var k = invite;
    };
    agoraClient.onRemoteInvitationReceivedByPeer = (AgoraRtmRemoteInvitation invite) {
      var l = invite;
    };
  }

  inviteCall(AgoraRtmClient agoraClient, String id, String channel) async {
    //await notifyCallEntering(id, channel);
    AgoraRtmLocalInvitation invitation = AgoraRtmLocalInvitation(id, channelId: channel, content: id);
    await agoraClient.sendLocalInvitation(invitation.toJson());
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


  listenCall() {
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


}

class Call {
  Call(this.number);
  String number;
  bool held = false;
  bool muted = false;
}