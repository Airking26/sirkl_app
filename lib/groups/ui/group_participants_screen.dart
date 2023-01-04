import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/src/scroll_view/member_scroll_view/stream_member_list_view.dart';
import 'package:sirkl/common/view/stream_chat/src/stream_chat.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';


class GroupParticipantScreen extends StatefulWidget {
  const GroupParticipantScreen({Key? key}) : super(key: key);

  @override
  State<GroupParticipantScreen> createState() => _GroupParticipantScreenState();
}

class _GroupParticipantScreenState extends State<GroupParticipantScreen> {

  final _chatController = Get.put(ChatsController());
  final _commonController = Get.put(CommonController());

  late final StreamMemberListController _memberListController =
  StreamMemberListController(
    limit: 25,
    filter: Filter.and(
      [
        Filter.notIn("id", [StreamChat.of(context).currentUser!.id, 'bot_one', 'bot_two', 'bot_three']),
      ],
    ),
    sort: [
      const SortOption(
        'name',
        direction: 1,
      ),
    ], channel: _chatController.channel.value!,
  );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(
      children: [
        buildAppbar(context),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: StreamMemberListView(controller: _memberListController, onMemberTap: (member){
                _commonController.userClicked.value = userFromJson(json.encode(member.user?.extraData['userDTO']));
                Get.to(() => const ProfileElseScreen(fromConversation: false));
              },),
            ),
          ),
        ),
      ],
    ));
  }

  Container buildAppbar(BuildContext context) {
    return Container(
      height: 115,
      margin: const EdgeInsets.only(bottom: 0.25),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 0.01), //(x,y)
            blurRadius: 0.01,
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Get.isDarkMode ? const Color(0xFF113751) : Colors.white,
              Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 44.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    "assets/images/arrow_left.png",
                    color: Get.isDarkMode
                        ? Colors.transparent
                        : Colors.transparent,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                   "Members" ,
                  style: TextStyle(
                      color: Get.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              IconButton(
                  onPressed: () {
                  },
                  icon: Image.asset(
                    "assets/images/more.png",
                    color:Colors.transparent,
                  )),
            ],
          ),
        ),
      ),
    );
  }

}
