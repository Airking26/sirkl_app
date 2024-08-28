import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/model/request_to_join_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/repo/chats_repo.dart';

import 'profile_controller.dart';

class ChatsController extends GetxController {
  final box = GetStorage();

  ProfileController get _profileController => Get.find<ProfileController>();

  var index = 0.obs;
  var searchIsActive = false.obs;
  var searchIsActiveInCompose = false.obs;
  var chipsList = <UserDTO>[].obs;
  var chipsListAddUsers = <UserDTO>[].obs;
  var requestsWaiting = <UserDTO>[].obs;
  var query = "".obs;
  var messageSending = false.obs;
  var isEditingProfile = false.obs;
  var usernameElseTextEditingController = TextEditingController().obs;
  var addUserQuery = "".obs;
  var groupNameIsEmpty = true.obs;
  var contactAddIsEmpty = true.obs;
  var groupTextController = TextEditingController().obs;
  var fromGroupCreation = false.obs;
  var fromGroupJoin = false.obs;
  var isEditingGroup = false.obs;
  var needToRefresh = false.obs;
  Rx<Channel?> channel = (null as Channel?).obs;
  var retryProgress = false.obs;

  var sliderShare = 1.0.obs;
  var sendingMessageMode = 0.obs;
  var groupType = 0.obs;
  var groupVisibility = 0.obs;
  var groupPaying = 0.obs;
  var groupTypeCollapsed = true.obs;
  var groupVisibilityCollapsed = true.obs;
  var groupPayingCollapsed = true.obs;

  Future<String> createInbox(InboxCreationDto inboxCreationDto) async =>
      await ChatRepo.createInbox(inboxCreationDto);

  resetChannel() => channel = (null as Channel?).obs;

  Future<void> checkOrCreateChannel(
      String himId, StreamChatClient client, String myId) async {
    channel.value = client.channel(
      'try',
      extraData: {
        'members': [
          myId,
          himId,
        ],
        "isConv": true
      },
    );

    await channel.value!.watch();
  }

  Future<void> checkOrCreateChannelWithId(
      StreamChatClient client, String channelId) async {
    channel.value =
        client.channel('try', id: channelId, extraData: {"isConv": true});
    await channel.value!.watch();
  }

  Future<String?> getEthFromEns(String ens, String wallet) async {
    String? eth = await ChatRepo.ethFromEns(ens);

    if (eth != '0' && eth != "" && eth?.toLowerCase() != wallet.toLowerCase()) {
      _profileController.isUserExists.value =
          await _profileController.getUserByWallet(eth!);
    }
    return eth;
  }

  Future<void> deleteInbox(String id) async {
    await ChatRepo.deleteInbox(id);
  }

  Future<bool> requestToJoinGroup(RequestToJoinDto requestToJoinDTO) async {
    try {
      await ChatRepo.requestToJoinGroup(requestToJoinDTO);
      return true;
    } catch (err) {}
    return false;
  }

  Future<bool> acceptDeclineRequest(RequestToJoinDto requestToJoinDto) async {
    try {
      await ChatRepo.acceptDeclineRequest(requestToJoinDto);
      return true;
    } catch (err) {}
    return false;
  }

  Future<void> retrieveRequestsWaiting(String channelId) async {
    requestsWaiting.value = await ChatRepo.getRequestsWaiting(channelId);
  }
}
