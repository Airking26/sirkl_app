import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/chats/service/chats_service.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/profile/controller/profile_controller.dart';

class ChatsController extends GetxController{

  final box = GetStorage();
  var index = 0.obs;
  var searchIsActive = false.obs;
  var chipsList = <UserDTO>[].obs;
  var chipsListAddUsers = <UserDTO>[].obs;
  var query = "".obs;
  final _chatService = ChatsService();
  final _homeService = HomeService();
  final _profileController = Get.put(ProfileController());
  var messageSending = false.obs;
  var isEditingProfile = false.obs;
  var usernameElseTextEditingController = TextEditingController().obs;
  var isBroadcastList = false.obs;
  var addUserQuery = "".obs;
  var sendingMessageMode = 0.obs;
  var groupType = 0.obs;
  var groupVisibility = 0.obs;
  var groupTypeCollapsed = true.obs;
  var groupVisibilityCollapsed = true.obs;
  var groupNameIsEmpty = true.obs;
  var groupTextController = TextEditingController().obs;
  var fromGroupCreation = false.obs;
  Rx<Channel?> channel = (null as Channel?).obs;

  Future<String?> createInbox(InboxCreationDto inboxCreationDto) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _chatService.createInbox(accessToken, inboxCreationDtoToJson(inboxCreationDto));
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _chatService.createInbox(accessToken, inboxCreationDtoToJson(inboxCreationDto));
    }
    return req.body;
  }


  checkOrCreateChannel(String himId, StreamChatClient client, String myId) async{
    channel.value = client.channel(
      'try',
      extraData: {
        'members': [
          myId,
          himId,
        ],
        "isConv" : true
      },
    );
    await channel.value!.watch();
  }

  checkOrCreateChannelWithId(StreamChatClient client, String channelId) async{
    channel.value = client.channel(
      'try',
      id: channelId,
      extraData: {
        "isConv" : true
      }
    );
    await channel.value!.watch();
  }

  Future<String?> getEthFromEns(String ens, String wallet) async{
    String? eth = "";
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _chatService.ethFromEns(accessToken, ens);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _chatService.ethFromEns(accessToken, ens);
      if(request.isOk){
        eth = request.body;
        if(request.body != '0' && request.body != "" && request.body!.toLowerCase() != wallet.toLowerCase()){
          _profileController.isUserExists.value = await _profileController.getUserByWallet(request.body!);
        }
      }
    } else if(request.isOk){
      eth = request.body;
      if(request.body != '0' && request.body != "" && request.body!.toLowerCase() != wallet.toLowerCase()){
        _profileController.isUserExists.value = await _profileController.getUserByWallet(request.body!);
      }
    }
    return eth;
  }

  deleteInbox(String id) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _chatService.deleteInbox(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _chatService.deleteInbox(accessToken, id);
    }
  }


}