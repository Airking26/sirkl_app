import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/chats/service/chats_service.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/inbox_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:zego_zim/zego_zim.dart';

import '../../common/model/refresh_token_dto.dart';

class ChatsController extends GetxController{

  final box = GetStorage();
  final _chatsService = ChatsService();
  final _homeService = HomeService();

  Rx<PagingController<int, ZIMMessage>> chatPagingController = PagingController<int, ZIMMessage>(firstPageKey: 0).obs;
  var index = 0.obs;
  var searchIsActive = false.obs;
  var chipsList = <User>[].obs;
  var conv = ZIMConversation().obs;

  createInbox(InboxCreationDto inboxCreationDto) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _chatsService.createInbox(accessToken, inboxCreationDtoToJson(inboxCreationDto));
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _chatsService.createInbox(accessToken, inboxCreationDtoToJson(inboxCreationDto));
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

  retrieveMessages(String convID) async{
    ZIMMessageQueryConfig config = ZIMMessageQueryConfig();
    config.nextMessage = null;
    config.count = 50;
    config.reverse = true;
    return await ZIM.getInstance()!.queryHistoryMessage(convID, ZIMConversationType.peer, config).then((value){
          return value.messageList.reversed.toList();
    }).catchError((onError) {
    });
  }

  retrieveChats() async{
    ZIMConversationQueryConfig config = ZIMConversationQueryConfig();
    config.count = 12;
    config.nextConversation = null;
    return await ZIM.getInstance()!.queryConversationList(config).then((value) {
      return value.conversationList;
    });
  }
}