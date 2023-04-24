// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/chats/ui/nested_detailed_chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/controller/groups_controller.dart';
import 'package:sirkl/groups/ui/group_participants_screen.dart';
import 'package:sirkl/groups/ui/pinned_messages_screen.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

class CommunitySettingScreen extends StatefulWidget {
  const CommunitySettingScreen({Key? key}) : super(key: key);

  @override
  State<CommunitySettingScreen> createState() => _CommunitySettingScreenState();
}

class _CommunitySettingScreenState extends State<CommunitySettingScreen> {

  final _profileController = Get.put(ProfileController());
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final _chatController = Get.put(ChatsController());
  final _groupController = Get.put(GroupsController());
  final utils = Utils();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
      body: Obx(()=> Column(
        children: [
          buildAppbar(context),
          const SizedBox(height: 24,),
          Align(
            alignment: Alignment.center,
            child: ClipOval(
              child: SizedBox.fromSize(
                size: const Size.fromRadius(70),
                child: _chatController.channel.value!.extraData["image"] == null
                    ? TinyAvatar(
                    baseString: _chatController.channel.value!.extraData['name'] as String,
                    dimension: 140,
                    circular: true,
                    colourScheme: TinyAvatarColourScheme
                        .seascape)
                    : CachedNetworkImage(
                    imageUrl: _chatController.channel.value!.extraData["image"] as String,
                    color: Colors.white.withOpacity(0.0),
                    fit: BoxFit.cover,
                    colorBlendMode:
                    BlendMode.difference,
                    placeholder: (context, url) =>
                    const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xff00CB7D))),
                    errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")),
              ),
            ),
          ),
          const SizedBox(height: 32,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  var uri = await _profileController.createDynamicLink("/joinGroup?id=${_commonController.userClicked.value!.id!}");
                  Share.share("Join this group ${uri.toString()}");
                },
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 5 ,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_outlined, color : MediaQuery.of(context).platformBrightness == Brightness.dark ?  Colors.white : Colors.black),
                        const SizedBox(height: 4),
                        const Text("Share", style: TextStyle(fontFamily: "Gilroy"),)
                      ],),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: (){
                    pushNewScreen(context, screen: GroupParticipantScreen(fromChat: true));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Participants (${_chatController.channel.value!.memberCount!})", style: const TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                  ),
                ),

                Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.white : Colors.black,),
                InkWell(
                  onTap: () async {
                    if(_chatController.channel.value!.extraData["owner"] == _homeController.userMe.value.wallet!){
                      pushNewScreen(context, screen: const PinnedMessageScreen());
                    } else {
                      if (_chatController.channel.value!.extraData["owner"] ==
                          null) {
                        var creator = await _groupController
                            .retrieveCreatorGroup(
                            _chatController.channel.value!.id!);
                        if (!creator.isNullOrBlank!) {
                          if (creator == _homeController.userMe.value.wallet!) {
                            await _chatController.channel.value!.client
                                .updateChannelPartial(
                                _chatController.channel.value!.id!, 'try',
                                set: {
                                  "owner": _homeController.userMe.value.wallet!
                                });
                            utils.showToast(
                                context, "You are now the owner of the group");
                          } else {
                            utils.showToast(
                                context, 'You are not the owner of the group');
                          }
                        } else {
                          utils.showToast(context, 'Error. Try again later');
                        }
                      } else {
                        _commonController.userClicked.value =
                        await _profileController.getUserByWallet(
                            _chatController.channel.value!
                                .extraData["owner"] as String);
                        if (_commonController.userClicked.value!.wallet !=
                            _homeController.userMe.value.wallet!) {
                          pushNewScreen(
                            context, screen: const NestedDetailedChatScreen(
                            create: true));
                        }
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(_chatController.channel.value!.extraData["owner"] == _homeController.userMe.value.wallet! ? "Announcements" :_chatController.channel.value!.extraData["owner"] == null ? "Claim ownership" : "Contact owner", style: const TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                  ),
                ),
                Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.white : Colors.black,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Notifications", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                      SizedBox(
                        height: 20,
                        child: Switch(
                          value: !_chatController.channel.value!.isMuted,
                          onChanged: (active) async {
                            if(!active) {
                              await StreamChat
                                  .of(context)
                                  .client
                                  .muteChannel(
                                  _chatController.channel.value!.cid!);
                              _chatController.channel.refresh();
                            } else {
                              await StreamChat
                                  .of(context)
                                  .client
                                  .unmuteChannel(
                                  _chatController.channel.value!.cid!);
                              _chatController.channel.refresh();
                            }
                          } , activeColor: const Color(0xFF00CB7D), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                      )
                    ],
                  ),
                ),
                _chatController.channel.value!.extraData["owner"] == _homeController.userMe.value.wallet! ? const SizedBox() : Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,),
                _chatController.channel.value!.extraData["owner"] == _homeController.userMe.value.wallet! ? const SizedBox() :InkWell(
                  onTap: () async {
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Report", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                  ),
                ),
                _chatController.channel.value!.extraData["owner"] == _homeController.userMe.value.wallet! ? const SizedBox() :Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.white : Colors.black,),
                _chatController.channel.value!.extraData["owner"] == _homeController.userMe.value.wallet! ? const SizedBox() :InkWell(
                  onTap: () async {
                    showDialog(context: context,
                        barrierDismissible: true,
                        builder: (_) =>
                            CupertinoAlertDialog(
                              title: Text("Leave the group", style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Gilroy",
                                  color: MediaQuery
                                      .of(context)
                                      .platformBrightness == Brightness.dark ? Colors
                                      .white : Colors.black),),
                              content: Text("Are you sure?",
                                  style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Gilroy",
                                      color: MediaQuery
                                          .of(context)
                                          .platformBrightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.5)
                                          : Colors.black.withOpacity(0.5))),
                              actions: [
                                CupertinoDialogAction(child: Text("No",
                                    style: TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Gilroy",
                                        color: MediaQuery
                                            .of(context)
                                            .platformBrightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black)), onPressed: () {
                                  Get.back();
                                },),
                                CupertinoDialogAction(child: Text("Yes",
                                    style: TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Gilroy",
                                        color: MediaQuery
                                            .of(context)
                                            .platformBrightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black)),
                                  onPressed: () async {
                                    await _chatController.channel.value!.removeMembers([_homeController.id.value]);
                                    Get.back();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },)
                              ],
                            )
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Leave the group", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  _chatController.channel.value!.extraData['name'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w600,
                      color: MediaQuery.of(context)
                          .platformBrightness ==
                          Brightness.dark
                          ? Colors.white
                          : Colors.black),
                ),
              ), IconButton(
                  onPressed: () async {
                  },
                  icon:  Icon(Icons.more_vert_outlined, size: 30, color: MediaQuery.of(context)
                      .platformBrightness ==
                      Brightness.dark
                      ? Colors.transparent
                      : Colors.transparent))
            ],
          ),
        ),
      ),
    );
  }

}
