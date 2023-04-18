import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/chats/ui/add_user_to_group_screen.dart';
import 'package:sirkl/common/model/admin_dto.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/src/scroll_view/member_scroll_view/stream_member_list_view.dart';
import 'package:sirkl/common/view/stream_chat/src/stream_chat.dart';
import 'package:sirkl/groups/controller/groups_controller.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';


class GroupParticipantScreen extends StatefulWidget {
  bool fromChat;
  GroupParticipantScreen({Key? key, required this.fromChat}) : super(key: key);

  @override
  State<GroupParticipantScreen> createState() => _GroupParticipantScreenState();
}

class _GroupParticipantScreenState extends State<GroupParticipantScreen> {

  final _chatController = Get.put(ChatsController());
  final _groupController = Get.put(GroupsController());
  final _homeController = Get.put(HomeController());
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
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
        body: Column(
      children: [
        buildAppbar(context),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: StreamMemberListView(
                memberPage: true,
                userSlidableEnabled: widget.fromChat,
                onUserDeletePressed: (context, memberId) async {
                  await _chatController.channel.value?.removeMembers([memberId]);
                  await _memberListController.refresh();
                },
                onAdminPressed: (context, memberId, isAdmin) async {
                  await _groupController.changeAdminRole(AdminDto(idChannel: _chatController.channel.value!.id!, userToUpdate: memberId, makeAdmin: !isAdmin));
                  await _memberListController.refresh();
                },
                controller: _memberListController, onMemberTap: (member){
                _commonController.userClicked.value = userFromJson(json.encode(member.user?.extraData['userDTO']));
                pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: false));
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
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
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
              InkWell(
                onTap: (){Navigator.pop(context);},
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: ImageIcon(const AssetImage(
                    "assets/images/arrow_left.png",
                  ),color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                   "Members" ,
                  style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              _chatController.channel.value?.createdBy?.id == _homeController.id.value && widget.fromChat ||
                  _chatController.channel.value?.membership?.channelRole == "channel_moderator" ? IconButton(
                  onPressed: () {
                    pushNewScreen(context, screen: const AddUserToGroupScreen()).then((value) => _memberListController.refresh());
                  },
                  icon: Image.asset(
                    "assets/images/add_user.png",
                    width: 20, height: 20,
                    color:Colors.black,
                  )) : Container(),
            ],
          ),
        ),
      ),
    );
  }

}
