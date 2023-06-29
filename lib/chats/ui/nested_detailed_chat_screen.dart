import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';
import 'package:sirkl/global_getx/common/common_controller.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/global_getx/navigation/navigation_controller.dart';

import '../../global_getx/home/home_controller.dart';

class NestedDetailedChatScreen extends StatefulWidget {

  const NestedDetailedChatScreen({Key? key, required this.create, this.fromProfile = false, this.channelId}) : super(key: key);
  final bool create;
  final String? channelId;
  final bool fromProfile;

  @override
  State<NestedDetailedChatScreen> createState() =>
      _NestedDetailedChatScreenState();
}

class _NestedDetailedChatScreenState extends State<NestedDetailedChatScreen> {
  final utils = Utils();
  YYDialog dialogMenu = YYDialog();

  CommonController get _commonController => Get.find<CommonController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  HomeController get _homeController => Get.find<HomeController>();
  NavigationController get _navigationController => Get.find<NavigationController>();

  @override
  void initState() {
    _navigationController.hideNavBar.value = true;
    if(_commonController.userClicked.value != null) _commonController.checkUserIsInFollowing();
    if(widget.create) {
      _chatController.checkOrCreateChannel(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value, true);
    } else if(widget.channelId != null) {
      _chatController.checkOrCreateChannelWithId(StreamChat.of(context).client, widget.channelId!, true);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() => StreamChat(
          client: StreamChat.of(context).client,
          child: StreamChannel(channel: _chatController.nestedChannel.value!,
          child: ChannelPage(fromProfile: widget.fromProfile,))
        )
        ));
  }


}
