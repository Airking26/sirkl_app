// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/models/notification_added_admin_dto.dart';
import 'package:sirkl/models/report_dto.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/repositories/follow_repo.dart';
import 'package:sirkl/repositories/notification_repo.dart';
import 'package:sirkl/repositories/report_repo.dart';
import 'package:sirkl/repositories/user_repo.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

class CommonController extends GetxController {
  final box = GetStorage();

  Rx<UserDTO?> userClicked = (null as UserDTO?).obs;
  var userClickedFollowStatus = false.obs;
  var isCardExpandedList = <int>[].obs;
  var isSearchLoading = false.obs;
  var users = <UserDTO>[].obs;
  var gettingStoryAndContacts = true.obs;
  var query = "".obs;
  var contactAddLoading = false.obs;
  late StreamChannelListController controllerFriend;
  late StreamChannelListController controllerOthers;
  late StreamChannelListController communityFavoritesController;
  late StreamChannelListController communityOthersController;

  void refreshAllInbox() async {
    controllerFriend.refresh();
    controllerOthers.refresh();
  }

  void refreshCommunities() async {
    communityFavoritesController.refresh();
    communityOthersController.refresh();
  }

  Future<bool> addUserToSirkl(
      String id, StreamChatClient streamChatClient, String myId) async {
    contactAddLoading.value = true;
    var channel = await streamChatClient.queryChannel("try", channelData: {
      "members": [id, myId],
      "isConv": true
    });
    var meFollow =
        channel.channel?.extraData["${myId}_follow_channel"] as dynamic;
    if (meFollow == null || (meFollow != null && meFollow == false)) {
      meFollow = true;
    }
    await streamChatClient.updateChannelPartial(channel.channel!.id, "try",
        set: {"${myId}_follow_channel": meFollow});

    try {
      UserDTO newUser = await FollowRepo.addUserToSirkl(id);
      contactAddLoading.value = false;
      refreshAllInbox();
      if (!users.map((element) => element.id).contains(newUser.id)) {
        users.add(newUser);
      }
      userClickedFollowStatus.value = true;
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> removeUserToSirkl(
      String id, StreamChatClient streamChatClient, String value) async {
    var channel = await streamChatClient.queryChannel("try", channelData: {
      "members": [id, value]
    });
    var meFollow =
        channel.channel?.extraData["${value}_follow_channel"] as dynamic;
    if (meFollow == null || (meFollow != null && meFollow == true)) {
      meFollow = false;
    }
    await streamChatClient.updateChannelPartial(channel.channel!.id, "try",
        set: {"${value}_follow_channel": meFollow});
    try {
      UserDTO removedUser = await FollowRepo.removeUserToSirkl(id);

      refreshAllInbox();
      if (users.map((element) => element.id).contains(removedUser.id)) {
        users.removeWhere((e) => e.id == removedUser.id);
      }
      userClickedFollowStatus.value = false;

      return true;
    } catch (err) {}
    return false;
  }

  showSirklUsers(String id) async {
    gettingStoryAndContacts.value = true;

    try {
      List<UserDTO> following = await FollowRepo.getSirklUsers(id);

      users.clear();
      users.value = following;
      users.sort((a, b) {
        return a.userName!.toLowerCase().compareTo(b.userName!.toLowerCase());
      });
      users.refresh();
    } catch (err) {}

    gettingStoryAndContacts.value = false;
  }

  checkUserIsInFollowing() async {
    userClickedFollowStatus.value =
        await FollowRepo.checkUserIsInFollowing(userClicked.value!.id!);
  }

  getUserById(String id) async {
    UserDTO userDto = await UserRepo.getUserByID(id);
    userClicked.value = userDto;
  }

  Future<void> notifyAddedInGroup(
      NotificationAddedAdminDto notificationAddedAdminDto) async {
    await NotificationRepo.notifyAddedInGroup(notificationAddedAdminDto);
  }

  notifyUserAsAdmin(NotificationAddedAdminDto notificationAddedAdminDto) async {
    await NotificationRepo.notifyUserAsAdmin(notificationAddedAdminDto);
  }

  report(BuildContext context, ReportDto reportDTO) async {
    await ReportRepo.report(reportDTO);
    showToast(context, "Thank you! Your report has been correctly sent.");
  }
}
