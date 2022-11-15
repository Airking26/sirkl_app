import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/model/inbox_modification_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/src/stream_chat.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:zego_zim/zego_zim.dart';

import '../../interface/ZIMEventHandlerManager.dart';
import '../../utils.dart';
import '../dialog/custom_dial.dart';

class DetailedMessageScreenOtherSecond extends StatefulWidget {
  const DetailedMessageScreenOtherSecond({Key? key}) : super(key: key);

  @override
  State<DetailedMessageScreenOtherSecond> createState() =>
      _DetailedMessageScreenOtherSecondState();
}

class _DetailedMessageScreenOtherSecondState
    extends State<DetailedMessageScreenOtherSecond> {
  final utils = Utils();
  YYDialog dialogMenu = YYDialog();
  final _commonController = Get.put(CommonController());
  final _chatController = Get.put(ChatsController());
  final _homeController = Get.put(HomeController());
  final _textMessageController = TextEditingController();



  @override
  void initState() {
    _chatController.checkOrCreateChannel(_homeController, _commonController, StreamChat.of(context).client, StreamChat.of(context).currentUser!.id);
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
          child: ChannelPage())
        )));
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
                .removeUserToSirkl(_commonController.userClicked.value!.id!)) {
              utils.showToast(
                  context,
                  con.userRemovedofSirklRes.trParams({
                    "user": _commonController.userClicked.value!.userName.isNullOrBlank!?
                        _commonController.userClicked.value!.wallet! : _commonController.userClicked.value!.userName!
                  }));
            }
          } else {
            if (await _commonController
                .addUserToSirkl(_commonController.userClicked.value!.id!)) {
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
          Get.to(() => const ProfileElseScreen());
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
