// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';
import 'package:sirkl/common/model/inbox_dto.dart';
import 'package:sirkl/common/model/notification_added_admin_dto.dart';
import 'package:sirkl/common/model/report_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/repo/common_repo.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/repo/home_repo.dart';
import 'package:sirkl/repo/profile_repo.dart';
import 'package:sirkl/util/multi_load.util.dart';

import '../../common/model/refresh_token_dto.dart';
import '../../constants/save_pref_keys.dart';

class CommonController extends GetxController {

  final HomeRepo _homeService = HomeRepo();


  final box = GetStorage();

  Rx<UserDTO?> userClicked = (null as UserDTO?).obs;
  var userClickedFollowStatus = false.obs;
  var isCardExpandedList = <int>[].obs;
  var isLoadingUsers = true.obs;
  var users = <UserDTO>[].obs;
  var gettingStoryAndContacts = true.obs;
  var query = "".obs;
  var contactAddLoading = false.obs;
  late StreamChannelListController controllerFriend;
  late StreamChannelListController controllerOthers;

  void refreshAllInbox() async {
    List<StreamChannelListController> chatStreamControllers = [
      controllerFriend,
      controllerOthers
    ];
    MultiLoadUtil multiLoad = MultiLoadUtil();

    for (var element in chatStreamControllers) {
      multiLoad.startLoading();
      element.refresh().then((value) => multiLoad.stopLoading());
    }
    await multiLoad.isDone();
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
     UserDTO newUser = await CommonRepo.addUserToSirkl(id);
     contactAddLoading.value = false;
            refreshAllInbox();
        if (!users
            .map((element) => element.id)
            .contains(newUser.id)) {
          users.add(newUser);
        }
        userClickedFollowStatus.value = true;
     return true;
   } catch(err) {
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
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);
    try {
      UserDTO removedUser = await CommonRepo.removeUserToSirkl(id);
     
      refreshAllInbox();
      if (users
          .map((element) => element.id)
          .contains(removedUser.id)) {
        users.removeWhere(
            (e) => e.id == removedUser.id);
      }
      userClickedFollowStatus.value = false;
  
      return true;
    } catch(err) {

    }
    return false;
   
  }

  showSirklUsers(String id) async {
    gettingStoryAndContacts.value = true;


    try {
      List<UserDTO> following = await CommonRepo.getSirklUsers(id);
      
        users.clear();
        users.value = following;
        users.sort((a, b) {
          return a.userName!.toLowerCase().compareTo(b.userName!.toLowerCase());
        });
        users.refresh();
    } catch(err) {

    }

    gettingStoryAndContacts.value = false;
  }

  checkUserIsInFollowing() async {

     userClickedFollowStatus.value = await CommonRepo.checkUserIsInFollowing(userClicked.value!.id!);

  }

  getUserById(String id) async {

    UserDTO userDto = await ProfileRepo.getUserByID( id);

      userClicked.value = userDto;
    
  }

  Future<void> notifyAddedInGroup(
      NotificationAddedAdminDto notificationAddedAdminDto) async {

   await CommonRepo.notifyAddedInGroup(notificationAddedAdminDto);

  }

  notifyUserAsAdmin(NotificationAddedAdminDto notificationAddedAdminDto) async {

    await CommonRepo.notifyUserAsAdmin(notificationAddedAdminDto);

  }

  report(BuildContext context, ReportDto reportDTO, Utils utils) async {
    var accessToken = box.read(SharedPref.ACCESS_TOKEN);
    var refreshToken = box.read(SharedPref.REFRESH_TOKEN);

        await CommonRepo.report(reportDTO);
        utils.showToast(
            context, "Thank you! Your report has been correctly sent.");
  }
}
