
import 'dart:developer';

import 'package:zego_zim/zego_zim.dart';

class ZIMEventHandlerManager{
  static loadingEventHandler(){
    ZIMEventHandler.onConnectionStateChanged = (ZIM zim, ZIMConnectionState state, ZIMConnectionEvent event, Map<dynamic, dynamic> extendedData){
      log("onConnectionStateChanged");
    };

    ZIMEventHandler.onReceivePeerMessage = (ZIM zim, List<ZIMMessage> messageList, String fromUserID){
      var k = messageList;
      var l = fromUserID;
      var g = "";
    };
  }
}