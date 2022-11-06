
import 'dart:developer';

import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:zego_zim/zego_zim.dart';

class ZIMEventHandlerManager{

  static loadingEventHandler(PagingController pagingController){
    ZIMEventHandler.onConnectionStateChanged = (ZIM zim, ZIMConnectionState state, ZIMConnectionEvent event, Map<dynamic, dynamic> extendedData){
      log("onConnectionStateChanged");
    };

    ZIMEventHandler.onReceivePeerMessage = (ZIM zim, List<ZIMMessage> messageList, String fromUserID){
      pagingController.itemList!.insert(0, messageList.first);
      pagingController.refresh();
    };
  }
}