import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/model/inbox_dto.dart';
import 'package:sirkl/common/model/notification_added_admin_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/service/common_service.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/profile/service/profile_service.dart';

import '../model/refresh_token_dto.dart';

class CommonController extends GetxController{

  final HomeService _homeService = HomeService();
  final CommonService _commonService = CommonService();
  final ProfileService _profileService = ProfileService();
  final box = GetStorage();

  Rx<UserDTO?> userClicked = (null as UserDTO?).obs;
  var userClickedFollowStatus = false.obs;
  var isCardExpandedList = <int>[].obs;
  var isLoadingUsers = true.obs;
  var users = <UserDTO>[].obs;
  var gettingStoryAndContacts = true.obs;
  var query = "".obs;
  var queryHasChanged = false.obs;
  var inboxClicked = InboxDto().obs;
  var refreshInboxes = false.obs;

  Future<bool> addUserToSirkl(String id, StreamChatClient streamChatClient, String myId) async{
    var channel = await streamChatClient.queryChannel("try", channelData: {"members": [id, myId], "isConv": true});
    var meFollow = channel.channel?.extraData["${myId}_follow_channel"] as dynamic;
    if(meFollow == null || (meFollow != null && meFollow == false)) {
      meFollow = true;
    }
    await streamChatClient.updateChannelPartial(channel.channel!.id, "try", set: {"${myId}_follow_channel" : meFollow});
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.addUserToSirkl(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _commonService.addUserToSirkl(accessToken, id);
      if(request.isOk) {
        refreshInboxes.value = true;
        if(!users.map((element) => element.id).contains(userFromJson(json.encode(request.body)).id)) {
          users.add(userFromJson(json.encode(request.body)));
        }
        userClickedFollowStatus.value = true;
        return true;
      } else {
        return false;
      }
    } else if(request.isOk) {
      refreshInboxes.value = true;
      if(!users.map((element) => element.id).contains(userFromJson(json.encode(request.body)).id)) {
        users.add(userFromJson(json.encode(request.body)));
      }
      userClickedFollowStatus.value = true;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeUserToSirkl(String id, StreamChatClient streamChatClient, String value) async{
    var channel = await streamChatClient.queryChannel("try", channelData: {"members": [id, value]});
    var meFollow = channel.channel?.extraData["${value}_follow_channel"] as dynamic;
    if(meFollow == null || (meFollow != null && meFollow == true)) {
      meFollow = false;
    }
    await streamChatClient.updateChannelPartial(channel.channel!.id, "try", set: {"${value}_follow_channel" : meFollow});
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.removeUserToSirkl(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _commonService.removeUserToSirkl(accessToken, id);
      if(request.isOk) {
        refreshInboxes.value = true;
        if(users.map((element) => element.id).contains(userFromJson(json.encode(request.body)).id)) {
          users.removeWhere((e) => e.id == userFromJson(json.encode(request.body)).id);
        }
        userClickedFollowStatus.value = false;
       return true;
      } else {
        return false;
      }
    } else if(request.isOk) {
      refreshInboxes.value = true;
      if(users.map((element) => element.id).contains(userFromJson(json.encode(request.body)).id)) {
        users.removeWhere((e) => e.id == userFromJson(json.encode(request.body)).id);
      }
      userClickedFollowStatus.value = false;
      return true;
    } else {
      return false;
    }
  }

  showSirklUsers(String id) async{
    gettingStoryAndContacts.value = true;
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    Response<List<dynamic>> request;
    try{
      request = await _commonService.getSirklUsers(accessToken, id);
      if(request.isOk) {
        users.clear();
        users.value = request.body!.map<UserDTO>((user) => userFromJson(json.encode(user))).toList();
        users.sort((a,b){ return a.userName!.toLowerCase().compareTo(b.userName!.toLowerCase());});
        users.refresh();
      } else {
        gettingStoryAndContacts.value = false;
      }
    } on CastError{
        var requestToken = await _homeService.refreshToken(refreshToken!);
        var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
        accessToken = refreshTokenDto.accessToken!;
        box.write(con.ACCESS_TOKEN, accessToken);
        try {
          request = await _commonService.getSirklUsers(accessToken, id);
          if(request.isOk) {
            users.clear();
            users.value = request.body!.map<UserDTO>((user) => userFromJson(json.encode(user))).toList();
            users.sort((a,b){ return a.userName!.toLowerCase().compareTo(b.userName!.toLowerCase());});
            users.refresh();
          }
          else {
            gettingStoryAndContacts.value = false;
          }
        } on CastError{
          gettingStoryAndContacts.value = false;
        }
    }

    gettingStoryAndContacts.value = false;
  }

  checkUserIsInFollowing() async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.checkUserIsInFollowing(accessToken, userClicked.value!.id!);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _commonService.checkUserIsInFollowing(accessToken, userClicked.value!.id!);
      userClickedFollowStatus.value = request.body == "false" ? false : true;
    } else if(request.isOk){
      userClickedFollowStatus.value = request.body == "false" ? false : true;
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
      if(request.isOk) userClicked.value = userFromJson(json.encode(request.body));
    } else if(request.isOk) {
      userClicked.value = userFromJson(json.encode(request.body));
    }
  }

  notifyAddedInGroup(NotificationAddedAdminDto notificationAddedAdminDto) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.notifyAddedInGroup(accessToken, notificationAddedAdminDtoToJson(notificationAddedAdminDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      request = await _commonService.notifyAddedInGroup(accessToken, notificationAddedAdminDtoToJson(notificationAddedAdminDto));
    }
  }

  notifyUserAsAdmin(NotificationAddedAdminDto notificationAddedAdminDto) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.notifyUserAsAdmin(accessToken, notificationAddedAdminDtoToJson(notificationAddedAdminDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      request = await _commonService.notifyUserAsAdmin(accessToken, notificationAddedAdminDtoToJson(notificationAddedAdminDto));
    }
  }


}