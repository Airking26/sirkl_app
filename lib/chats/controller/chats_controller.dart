import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/chats/service/chats_service.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/model/inbox_dto.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/profile/controller/profile_controller.dart';

class ChatsController extends GetxController{

  final box = GetStorage();
  var index = 0.obs;
  var searchIsActive = false.obs;
  var chipsList = <UserDTO>[].obs;
  var searchToRefresh = true.obs;
  var query = "".obs;
  final _chatService = ChatsService();
  final _homeService = HomeService();
  final _profileController = Get.put(ProfileController());
  var messageHasBeenSent = false.obs;
  var messageSending = false.obs;

  Rx<Channel?> channel = (null as Channel?).obs;

  createInbox(InboxCreationDto inboxCreationDto) async{
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
    );
    await channel.value!.watch();
  }

  Future<String?> getEthFromEns(String ens) async{
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
        if(request.body != '0' && request.body != ""){
          _profileController.isUserExists.value = await _profileController.getUserByWallet(request.body!);
        }
      }
    } else if(request.isOk){
      eth = request.body;
      if(request.body != '0' && request.body != ""){
        _profileController.isUserExists.value = await _profileController.getUserByWallet(request.body!);
      }
    }
    return eth;
  }

  /*clearUnreadMessages(String id) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _chatsService.clearUnreadMessages(accessToken, id);
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _chatsService.clearUnreadMessages(accessToken, id);
      if(req.isOk) return inboxDtoFromJson(json.encode(req.body));
    } else if(req.isOk){
      return inboxDtoFromJson(json.encode(req.body));
    }
  }

  modifyInbox(String id, InboxModificationDto inboxModificationDto) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _chatsService.modifyInbox(accessToken, id, inboxModificationDtoToJson(inboxModificationDto));
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _chatsService.modifyInbox(accessToken, id, inboxModificationDtoToJson(inboxModificationDto));
      if(req.isOk) return inboxDtoFromJson(json.encode(req.body));
    } else if(req.isOk){
      return inboxDtoFromJson(json.encode(req.body));
    }
  }

  retrieveInboxes(int offset) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _chatsService.retrieveInboxes(accessToken, offset.toString());
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _chatsService.retrieveInboxes(accessToken, offset.toString());
      if(req.isOk) return req.body!.map<InboxDto>((inboxDto) => inboxDtoFromJson(json.encode(inboxDto))).toList();
    } else if(req.isOk) {
      return req.body!.map<InboxDto>((inboxDto) => inboxDtoFromJson(json.encode(inboxDto))).toList();
    }
  }

  Future<List<InboxDto>> searchInInboxes(String search) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _chatsService.searchInInboxes(accessToken, search);
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _chatsService.searchInInboxes(accessToken, search);
      if(req.isOk) {
        return req.body!.map<InboxDto>((inboxDto) => inboxDtoFromJson(json.encode(inboxDto))).toList();
      } else {
        return [];
      }
    } else if(req.isOk){
      return req.body!.map<InboxDto>((inboxDto) => inboxDtoFromJson(json.encode(inboxDto))).toList();
    } else {
      return [];
    }
  }
  
  bulkPeerMessages(List<InboxCreationDto> listInboxCreationDto) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _chatsService.bulkPeerMessage(accessToken, inboxCreationListDtoToJson(listInboxCreationDto));
    if(401 == 401) {
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _chatsService.bulkPeerMessage(accessToken, inboxCreationListDtoToJson(listInboxCreationDto));
    }
  }

  retrieveMessages(String convID, ZIMMessage? zimMessage) async{
    ZIMMessageQueryConfig config = ZIMMessageQueryConfig();
    config.nextMessage = zimMessage;
    config.count = 10;
    config.reverse = true;
    return await ZIM.getInstance()!.queryHistoryMessage(convID, ZIMConversationType.peer, config).then((value){
          lastItem.value = value.messageList.isEmpty ? null : value.messageList.reversed.toList().last;
          return value.messageList.reversed.toList();
    }).catchError((onError) {
    });
  }

  retrieveChats(ZIMConversation? zimConversation) async{
    var list = [];
    ZIMConversationQueryConfig conversationQueryConfig = ZIMConversationQueryConfig();
    conversationQueryConfig.count = 9;
    conversationQueryConfig.nextConversation = zimConversation;
    ZIMUserInfoQueryConfig userInfoQueryConfig = ZIMUserInfoQueryConfig();
    userInfoQueryConfig.isQueryFromServer = true;
    return await ZIM.getInstance()!.queryConversationList(conversationQueryConfig).then((value) async {
      if(value.conversationList.isNotEmpty){
      var queryUsersInfos = await ZIM.getInstance()!.queryUsersInfo(value.conversationList.map((e) => e.conversationID).toList(), userInfoQueryConfig);
      list = value.conversationList;
      for (var e in queryUsersInfos.userList) {
        var index = list.indexWhere((element) => element.conversationID == e.baseInfo.userID);
        list[index].conversationAvatarUrl = e.userAvatarUrl;
        list[index].conversationName = e.baseInfo.userName;
        lastConv.value = list.last;
      }
      convList.value = list as List<ZIMConversation>;
      return list;
      } else {
        return list;
      }
    });
  }*/


}