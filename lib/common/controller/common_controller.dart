import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/common/model/inbox_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/service/common_service.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/home/service/home_service.dart';

import '../model/refresh_token_dto.dart';

class CommonController extends GetxController{

  final HomeService _homeService = HomeService();
  final CommonService _commonService = CommonService();
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

  Future<bool> addUserToSirkl(String id, StreamChatClient streamChatClient, String value) async{
    var channel = await streamChatClient.queryChannel("try", channelData: {"members": [id, value]});
    var followers = channel.channel?.extraData["isInFollowing"] as List<dynamic>?;
    var followCount = channel.channel?.extraData["followCount"] as dynamic;
    if(followers != null && !followers.contains(id)) followers.add(id);
    if(followCount != null) followCount++;
    await streamChatClient.updateChannelPartial(channel.channel!.id, "try", set: {"isInFollowing": followers ?? [id], "followCount": followCount ?? 1});
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
        if(!users.map((element) => element.id).contains(userFromJson(json.encode(request.body)).id)) {
          users.add(userFromJson(json.encode(request.body)));
        }
        userClickedFollowStatus.value = true;
        return true;
      } else {
        return false;
      }
    } else if(request.isOk) {
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
    var followers = channel.channel?.extraData["isInFollowing"] as List<dynamic>?;
    var followCount = channel.channel?.extraData["followCount"] as dynamic;
    if(followers != null && followers.contains(id)){
      followers.remove(id);
      if(followCount != null && followCount != 0) followCount--;
    }
    await streamChatClient.updateChannelPartial(channel.channel!.id, "try", set: {"isInFollowing": followers ?? [], "followCount": followCount ?? 0});
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
        if(users.map((element) => element.id).contains(userFromJson(json.encode(request.body)).id)) {
          users.removeWhere((e) => e.id == userFromJson(json.encode(request.body)).id);
        }
        userClickedFollowStatus.value = false;
       return true;
      } else {
        return false;
      }
    } else if(request.isOk) {
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

  searchInSirklUsers(String substring, String offset) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.searchSirklUsers(accessToken, substring, offset);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _commonService.searchSirklUsers(accessToken, substring, offset);
      if(request.isOk) return request.body!.map<UserDTO>((user) => userFromJson(json.encode(user))).toList();
    } else if(request.isOk){
      return request.body!.map<UserDTO>((user) => userFromJson(json.encode(user))).toList();
    }
  }

  searchUsers(String substring, String offset) async{
      var accessToken = box.read(con.ACCESS_TOKEN);
      var refreshToken = box.read(con.REFRESH_TOKEN);
      var request = await _commonService.searchUsers(accessToken, substring, offset);
      if (request.statusCode == 401) {
        var requestToken = await _homeService.refreshToken(refreshToken!);
        var refreshTokenDto = refreshTokenDtoFromJson(
            json.encode(requestToken.body));
        accessToken = refreshTokenDto.accessToken!;
        box.write(con.ACCESS_TOKEN, accessToken);
        request =
        await _commonService.searchUsers(accessToken, substring, offset);
        if (request.isOk) {
          return request.body!.map<UserDTO>((user) =>
            userFromJson(json.encode(user))).toList();
        }
      } else if (request.isOk) {
        return request.body!.map<UserDTO>((user) =>
            userFromJson(json.encode(user))).toList();
      }
  }

  defineUserFromChannel(String? userId, StreamChatClient streamChatClient) async {
    if(userId != null) {
      var users = await streamChatClient.queryUsers(
          filter: Filter.in_("id", [userId]));
      userClicked.value =
          userFromJson(json.encode(users.users.first.extraData['userDTO']));
    }
  }
}