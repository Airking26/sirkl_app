import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/inbox_controller.dart';
import 'package:sirkl/views/global/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

import '../../controllers/home_controller.dart';

class DetailedChatScreen extends StatefulWidget {
  const DetailedChatScreen(
      {Key? key,
      required this.create,
      this.fromProfile = false,
      this.channelId,
      this.resetChannel = true})
      : super(key: key);
  final bool create;
  final String? channelId;
  final bool fromProfile;
  final bool resetChannel;

  @override
  State<DetailedChatScreen> createState() => _DetailedChatScreenState();
}

class _DetailedChatScreenState extends State<DetailedChatScreen> {
  CommonController get _commonController => Get.find<CommonController>();
  InboxController get _chatController => Get.find<InboxController>();
  HomeController get _homeController => Get.find<HomeController>();

  @override
  void initState() {
    if (widget.resetChannel) _chatController.resetChannel();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_commonController.userClicked.value != null) {
        _commonController.checkUserIsInFollowing();
      }
      if (widget.create) {
        _chatController.watchChannelWithMembers(
            _commonController.userClicked.value!.id!,
            StreamChat.of(context).client,
            _homeController.id.value);
      } else if (widget.channelId != null) {
        _chatController.watchChannelWithId(
            StreamChat.of(context).client, widget.channelId!);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? const Color(0xFF102437)
                : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() {
          return _chatController.channel.value == null
              ? Center(
                  child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: SColors.activeColor)),
                )
              : StreamChat(
                  client: StreamChat.of(context).client,
                  child: StreamChannel(
                      channel: _chatController.channel.value!,
                      child: ChannelPage(fromProfile: widget.fromProfile)));
        }));
  }

  @override
  void dispose() {
    _chatController.resetChannel();
    super.dispose();
  }
}
