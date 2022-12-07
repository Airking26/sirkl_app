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
import 'package:sirkl/profile/ui/profile_else_screen.dart';

class DetailedChatScreen extends StatefulWidget {

  const DetailedChatScreen({Key? key, required this.create}) : super(key: key);
  final bool create;

  @override
  State<DetailedChatScreen> createState() =>
      _DetailedChatScreenState();
}

class _DetailedChatScreenState extends State<DetailedChatScreen> {
  final utils = Utils();
  YYDialog dialogMenu = YYDialog();
  final _commonController = Get.put(CommonController());
  final _chatController = Get.put(ChatsController());
  final _homeController = Get.put(HomeController());

  @override
  void initState() {
    if(widget.create) _chatController.checkOrCreateChannel(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() => StreamChat(
          client: StreamChat.of(context).client,
          child: StreamChannel(channel: _chatController.channel.value!,
          child: const ChannelPage())
        )
        ));
  }

  YYDialog dialogPopMenu(BuildContext context) {
    return YYDialog().build(context)
      ..width = 180
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor =
          Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor =
          Get.isDarkMode ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: () async {
          dialogMenu.dismiss();
          if (_commonController.userClickedFollowStatus.value) {
            if (await _commonController
                .removeUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)) {
              utils.showToast(
                  context,
                  con.userRemovedofSirklRes.trParams({
                    "user": _commonController.userClicked.value!.userName.isNullOrBlank!?
                        _commonController.userClicked.value!.wallet! : _commonController.userClicked.value!.userName!
                  }));
            }
          } else {
            if (await _commonController
                .addUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)) {
              utils.showToast(
                  context,
                  con.userAddedToSirklRes.trParams({
                    "user": _commonController.userClicked.value!.userName.isNullOrBlank! ?
                        _commonController.userClicked.value!.wallet! : _commonController.userClicked.value!.userName!
                  }));
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _commonController.userClickedFollowStatus.value
                    ? con.removeOfMySirklRes.tr
                    : con.addToMySirklRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () {
          Get.to(() => const ProfileElseScreen(fromConversation: true));
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                con.profileTabRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                con.reportRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..show();
  }

}
