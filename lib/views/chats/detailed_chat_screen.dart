import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/view/circular_indicator/my_circular_indicator.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/controllers/chats_controller.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';

import '../../controllers/home_controller.dart';

class DetailedChatScreen extends StatefulWidget {

  const DetailedChatScreen({Key? key, required this.create, this.fromProfile = false, this.channelId, this.resetChannel = true}) : super(key: key);
  final bool create;
  final String? channelId;
  final bool fromProfile;
  final bool resetChannel;

  @override
  State<DetailedChatScreen> createState() =>
      _DetailedChatScreenState();
}

class _DetailedChatScreenState extends State<DetailedChatScreen> {
  final utils = Utils();
  YYDialog dialogMenu = YYDialog();
  CommonController get _commonController => Get.find<CommonController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  HomeController get _homeController => Get.find<HomeController>();

  @override
  void initState() {
    if(widget.resetChannel) _chatController.resetChannel();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(_commonController.userClicked.value != null) _commonController.checkUserIsInFollowing();
      if(widget.create) {
        _chatController.checkOrCreateChannel(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value);
      } else if(widget.channelId != null) {
        _chatController.checkOrCreateChannelWithId(StreamChat.of(context).client, widget.channelId!);
      }
    });
    super.initState();
  }
  


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() {

          
          return _chatController.channel.value == null? MyCircularLoader(color: SColors.activeColor,):
       
        StreamChat(
          client: StreamChat.of(context).client,
          child: StreamChannel(
            channel: _chatController.channel.value!,

            child: ChannelPage(fromProfile: widget.fromProfile))
        );
        }
        
        ));
  }


}
