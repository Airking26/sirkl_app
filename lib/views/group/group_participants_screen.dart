import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sirkl/common/model/admin_dto.dart';
import 'package:sirkl/common/model/notification_added_admin_dto.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';
import 'package:sirkl/global_getx/common/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/src/scroll_view/member_scroll_view/stream_member_list_view.dart';
import 'package:sirkl/global_getx/groups/groups_controller.dart';
import 'package:sirkl/global_getx/web3/web3_controller.dart';

import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../global_getx/home/home_controller.dart';
import '../chats/add_user_to_group_screen.dart';
import '../profile/profile_else_screen.dart';


class GroupParticipantScreen extends StatefulWidget {

  const GroupParticipantScreen({Key? key}) : super(key: key);

  @override
  State<GroupParticipantScreen> createState() => _GroupParticipantScreenState();
}

class _GroupParticipantScreenState extends State<GroupParticipantScreen> {

  ChatsController get _chatController => Get.find<ChatsController>();
  GroupsController get _groupController => Get.find<GroupsController>();
  HomeController get _homeController => Get.find<HomeController>();
  CommonController get _commonController => Get.find<CommonController>();
  Web3Controller get _web3Controller => Get.find<Web3Controller>();

  late final StreamMemberListController _memberListController =
  StreamMemberListController(
    limit: 25,
    filter: Filter.and(
      [
        Filter.notIn("id", const ['bot_one', 'bot_two', 'bot_three']),
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
    return Obx(() => Scaffold(
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
                userSlidableEnabled: _chatController.channel.value?.createdBy?.id == _homeController.id.value ||
                    _chatController.channel.value?.membership?.channelRole == "channel_moderator",
                onUserDeletePressed: (context, memberId, wallet) async {
                  if(_chatController.channel.value!.extraData["isGroupPaying"] != null && _chatController.channel.value!.extraData["isGroupPaying"] as bool ){
                    AlertDialog alert = _web3Controller.blockchainInfo("Please, wait while the transaction is processed. This may take some time.");
                    var connector = await _web3Controller.connect();
                    connector.onSessionConnect.subscribe((args) async {
                      await _web3Controller.kickMemberMethod(connector, args, _chatController.channel.value!, _homeController.userMe.value.wallet!, alert, memberId, _memberListController, wallet!);
                    });
                  } else {
                    await _chatController.channel.value?.removeMembers(
                        [memberId]);
                    await _memberListController.refresh();
                  }
                },
                onAdminPressed: (context, memberId, isAdmin, wallet) async {
                  if(_chatController.channel.value!.extraData["isGroupPaying"] != null && _chatController.channel.value!.extraData["isGroupPaying"] as bool ){
                    if(isAdmin){
                      AlertDialog alert = _web3Controller
                          .blockchainInfo(
                          "Please, wait while the transaction is processed. This may take some time.");
                      var connector = await _web3Controller
                          .connect();
                      connector.onSessionConnect.subscribe((args) async {
                        await _web3Controller.removeCreatorMethod(context, connector, args, _chatController.channel.value!, _homeController.userMe.value.wallet!, alert, memberId, _memberListController, wallet!);
                      });
                  } else {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) =>
                              CupertinoAlertDialog(
                                title: Text(
                                  "Shares To Give",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                      fontFamily:
                                      "Gilroy",
                                      color: MediaQuery
                                          .of(context)
                                          .platformBrightness ==
                                          Brightness
                                              .dark
                                          ? Colors
                                          .white
                                          : Colors
                                          .black),
                                ),
                                content: Material(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                            "By making another user co-creator, you can share percentages of your shares with him.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "Gilroy",
                                                color: MediaQuery
                                                    .of(context)
                                                    .platformBrightness ==
                                                    Brightness.dark
                                                    ? Colors.white
                                                    .withOpacity(0.5)
                                                    : Colors.black
                                                    .withOpacity(0.5))),
                                        const SizedBox(height: 16,),
                                        Obx(() =>
                                            Slider(
                                                activeColor: SColors
                                                    .activeColor,
                                                inactiveColor: Colors.grey,
                                                value: _chatController
                                                    .sliderShare.value,
                                                max: 79,
                                                min: 0,
                                                label: _chatController
                                                    .sliderShare.round()
                                                    .toString(),
                                                divisions: 78,
                                                onChanged: (e) {
                                                  _chatController.sliderShare
                                                      .value = e;
                                                })),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text("Cancel",
                                        style: TextStyle(
                                            fontSize:
                                            16,
                                            fontWeight:
                                            FontWeight
                                                .w600,
                                            fontFamily:
                                            "Gilroy",
                                            color: MediaQuery
                                                .of(context)
                                                .platformBrightness ==
                                                Brightness
                                                    .dark
                                                ? Colors
                                                .white
                                                : Colors
                                                .black)),
                                    onPressed:
                                        () async {
                                      Get.back();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text("Confirm",
                                        style: TextStyle(
                                            fontSize:
                                            16,
                                            fontWeight:
                                            FontWeight
                                                .w600,
                                            fontFamily:
                                            "Gilroy",
                                            color: MediaQuery
                                                .of(context)
                                                .platformBrightness ==
                                                Brightness
                                                    .dark
                                                ? Colors
                                                .white
                                                : Colors
                                                .black)),
                                    onPressed:
                                        () async {
                                      Get.back();
                                      AlertDialog alert = _web3Controller
                                          .blockchainInfo(
                                          "Please, wait while the transaction is processed. This may take some time.");
                                      var connector = await _web3Controller
                                          .connect();
                                      connector.onSessionConnect.subscribe((
                                          args) async {
                                        await _web3Controller.addCreatorMethod(
                                          context,
                                            connector,
                                            args,
                                            _chatController.channel.value!,
                                            _homeController.userMe.value
                                                .wallet!,
                                            alert,
                                            memberId,
                                            _memberListController,
                                            wallet!,
                                            _chatController.sliderShare.value);
                                      });
                                    },
                                  ),
                                ],
                              ));
                    }
                  } else {
                    await _groupController.changeAdminRole(
                        AdminDto(idChannel: _chatController.channel.value!.id!,
                            userToUpdate: memberId,
                            makeAdmin: !isAdmin));
                    await _memberListController.refresh();
                    if (!isAdmin) {
                      await _commonController.notifyUserAsAdmin(
                        NotificationAddedAdminDto(
                            idUser: memberId, idChannel: _chatController.channel
                            .value!.id!, channelName: _chatController.channel
                            .value!.extraData["nameOfGroup"] as String));
                    }
                  }
                },
                controller: _memberListController, onMemberTap: (member){
                  if(_homeController.id.value != member.user!.id) {
                    _commonController.userClicked.value =
                        userFromJson(json.encode(member.user
                            ?.extraData['userDTO']));
                    pushNewScreen(context, screen: const ProfileElseScreen(
                      fromConversation: false,));
                  }
              },),
            ),
          ),
        ),
      ],
    )));
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
        padding: const EdgeInsets.only(top: 24.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){Navigator.pop(context);},
                child: Icon(Icons.keyboard_arrow_left_rounded,size: 42,color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
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
              _chatController.channel.value?.createdBy?.id == _homeController.id.value ||
                  _chatController.channel.value?.membership?.channelRole == "channel_moderator" ? IconButton(
                  onPressed: () {
                    pushNewScreen(context, screen: const AddUserToGroupScreen()).then((value) => _memberListController.refresh());
                  },
                  icon: Image.asset(
                    "assets/images/add_user.png",
                    width: 20, height: 20,
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                  )) : IconButton(onPressed: (){}, icon :const Icon(Icons.add, color: Colors.transparent, size: 24,)),
            ],
          ),
        ),
      ),
    );
  }

}
