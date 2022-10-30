
import 'dart:developer';

import 'package:get/get.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:zego_zim/zego_zim.dart';

class ZIMEventHandlerManager{

  static loadingEventHandler(ChatsController chatController){
    ZIMEventHandler.onConnectionStateChanged = (ZIM zim, ZIMConnectionState state, ZIMConnectionEvent event, Map<dynamic, dynamic> extendedData){
      log("onConnectionStateChanged");
    };

    ZIMEventHandler.onReceivePeerMessage = (ZIM zim, List<ZIMMessage> messageList, String fromUserID){
      chatController.chatPagingController.value.itemList!.insert(0, messageList.first);
      chatController.chatPagingController.value.refresh();
    };
  }
}