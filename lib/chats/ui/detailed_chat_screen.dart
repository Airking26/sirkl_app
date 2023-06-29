import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';

import '../../global_getx/home/home_controller.dart';

class DetailedChatScreen extends StatefulWidget {

  const DetailedChatScreen({Key? key, required this.create, this.fromProfile = false, this.channelId}) : super(key: key);
  final bool create;
  final String? channelId;
  final bool fromProfile;

  @override
  State<DetailedChatScreen> createState() =>
      _DetailedChatScreenState();
}

class _DetailedChatScreenState extends State<DetailedChatScreen> {
  final utils = Utils();
  YYDialog dialogMenu = YYDialog();
  final _commonController = Get.put(CommonController());
  final _chatController = Get.put(ChatsController());
 HomeController get _homeController => Get.find<HomeController>();
  final _navigationController = Get.put(NavigationController());

  @override
  void initState() {
    _navigationController.hideNavBar.value = true;
    if(_commonController.userClicked.value != null) _commonController.checkUserIsInFollowing();
    if(widget.create) {
      _chatController.checkOrCreateChannel(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value, false);
    } else if(widget.channelId != null) {
      _chatController.checkOrCreateChannelWithId(StreamChat.of(context).client, widget.channelId!, false);
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
          child: StreamChannel(channel: _chatController.channel.value!,
          child: ChannelPage(fromProfile: widget.fromProfile))
        )
        ));
  }


}
