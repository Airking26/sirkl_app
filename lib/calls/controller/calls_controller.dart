import 'package:agora_rtm/agora_rtm.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CallsController extends GetxController{

  Rx<AgoraRtmClient?> agoraClient = (null as AgoraRtmClient?).obs;

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


}

class Call {
  Call(this.number);
  String number;
  bool held = false;
  bool muted = false;
}