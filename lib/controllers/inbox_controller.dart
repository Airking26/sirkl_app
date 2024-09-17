import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/groups_controller.dart';
import 'package:sirkl/models/inbox_creation_dto.dart';
import 'package:sirkl/models/request_to_join_dto.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/repositories/inbox_repo.dart';
import 'package:sirkl/repositories/join_repo.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

import 'profile_controller.dart';

class InboxController extends GetxController {
  final box = GetStorage();

  ProfileController get _profileController => Get.find<ProfileController>();
  CommonController get _commonController => Get.find<CommonController>();
  GroupsController get _groupController => Get.find<GroupsController>();

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

  /// Function to create an Inbox
  Future<String> createInbox(InboxCreationDto inboxCreationDto) async {
    var id = await InboxRepo.createInbox(inboxCreationDto);
    _commonController.refreshAllInbox();
    return id;
  }

  /// Function to reset a channel
  resetChannel() => channel = (null as Channel?).obs;

  /// Function to return a channel (or create if it does not exist) based on members
  Future<void> watchChannelWithMembers(
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
    _commonController.refreshAllInbox();
  }

  /// Function to return a channel (or create if it does not exist) based on ID
  Future<void> watchChannelWithId(
      StreamChatClient client, String channelId) async {
    channel.value =
        client.channel('try', id: channelId, extraData: {"isConv": true});
    await channel.value!.watch();
    _commonController.refreshAllInbox();
  }

  /// Function to retrieve a ETH address from a ENS
  Future<String?> getEthFromEns(String ens, String wallet) async {
    String? eth = await InboxRepo.ethFromEns(ens);

    if (eth != '0' && eth != "" && eth?.toLowerCase() != wallet.toLowerCase()) {
      _profileController.isUserExists.value =
          await _profileController.getUserByWallet(eth!);
    }
    return eth;
  }

  /// Function to delete an inbox
  Future<void> deleteInbox(String id) async {
    await InboxRepo.deleteInbox(id);
  }

  /// Function to create a request to join
  Future<bool> requestToJoinGroup(RequestToJoinDto requestToJoinDTO) async {
    try {
      await JoinRepo.requestToJoinGroup(requestToJoinDTO);
      return true;
    } catch (err) {}
    return false;
  }

  /// Function to accept or decline a request to join
  Future<bool> acceptDeclineRequest(RequestToJoinDto requestToJoinDto) async {
    try {
      await JoinRepo.acceptDeclineRequest(requestToJoinDto);
      return true;
    } catch (err) {}
    return false;
  }

  /// Function to retrieve request waiting to join to be accepted (by admin)
  Future<void> retrieveRequestsWaiting(String channelId) async {
    requestsWaiting.value = await JoinRepo.getRequestsWaiting(channelId);
  }
}
