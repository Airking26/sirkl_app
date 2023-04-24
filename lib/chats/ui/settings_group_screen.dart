// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/chats/ui/nested_detailed_chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/ui/group_participants_screen.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:tiny_avatar/tiny_avatar.dart';


class SettingsGroupScreen extends StatefulWidget {
  const SettingsGroupScreen({Key? key}) : super(key: key);

  @override
  State<SettingsGroupScreen> createState() => _SettingsGroupScreenState();
}

class _SettingsGroupScreenState extends State<SettingsGroupScreen> {


  final _profileController = Get.put(ProfileController());
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final _chatController = Get.put(ChatsController());
  final _navigationController = Get.put(NavigationController());
  final _nameGroupController = TextEditingController();
  final utils = Utils();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
    body: Obx(() => SingleChildScrollView(child:
    Column(children: [
      buildAppbar(context),
      const SizedBox(height: 24,),
      InkWell(
        onTap: () async {
          if (_chatController
              .isEditingGroup.value) {
            await _profileController.getImageForGroup();
          }
        },
        child: Align(
          alignment: Alignment.center,
          child: ClipOval(
            child: SizedBox.fromSize(
              size: const Size.fromRadius(70),
              child: _chatController.channel.value!.extraData["picOfGroup"] == null && (!_chatController.isEditingGroup.value && !_profileController.urlPictureGroup.isNullOrBlank!)
                  ? TinyAvatar(
                  baseString: _chatController.channel.value!.extraData['nameOfGroup'] as String,
                  dimension: 140,
                  circular: true,
                  colourScheme: TinyAvatarColourScheme
                      .seascape)
                  : CachedNetworkImage(
                  imageUrl: !_profileController.urlPictureGroup.value.isNullOrBlank! ? _profileController.urlPictureGroup.value : _chatController.channel.value!.extraData["picOfGroup"] as String,
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
      ),
      const SizedBox(height: 32,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (_chatController.channel.value!.membership != null && _chatController.channel.value!.membership!.channelRole == "channel_member" && _chatController.channel.value?.createdBy?.id != _homeController.id.value) ?
          const SizedBox() : InkWell(
            onTap: () async {
              if(_chatController.channel.value!.membership != null && _chatController.channel.value!.membership!.channelRole == "channel_moderator" || _chatController.channel.value?.createdBy?.id == _homeController.id.value){
                _chatController.isEditingGroup.value = true;
              } else{
                await _chatController.channel.value!.addMembers([_homeController.id.value]);
                await _homeController.retrieveTokenStreamChat(StreamChat.of(context).client, null);
                Navigator.pop(context);
                _navigationController.hideNavBar.value = true;
                pushNewScreen(context, screen: DetailedChatScreen(create: false, channelId: _chatController.channel.value!.id,)).then((value) => _navigationController.hideNavBar.value = true);
              }
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
                    Icon( _chatController.channel.value!.membership != null && (_chatController.channel.value!.membership!.channelRole == "channel_moderator" || _chatController.channel.value?.createdBy?.id == _homeController.id.value) ? Icons.mode_edit_rounded : Icons.add_rounded, color : MediaQuery.of(context).platformBrightness == Brightness.dark ?  Colors.white : Colors.black),
                    const SizedBox(height: 4),
                    Text(_chatController.channel.value!.membership != null && (_chatController.channel.value!.membership!.channelRole == "channel_moderator" || _chatController.channel.value?.createdBy?.id == _homeController.id.value)? "Edit" : "Join", style: TextStyle(fontFamily: "Gilroy"),)
                  ],),
              ),
            ),
          ),
          SizedBox(width:  (_chatController.channel.value!.membership != null && _chatController.channel.value!.membership!.channelRole == "channel_member" && _chatController.channel.value?.createdBy?.id != _homeController.id.value) ? 0 : 16,),
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
                if(_chatController.channel.value!.membership != null) {
                  pushNewScreen(context, screen: GroupParticipantScreen(fromChat: true));
                } else {
                  utils.showToast(context, "You have to be a member to access this data");
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Participants (${_chatController.channel.value!.memberCount!})", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
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
                      value: _chatController.channel.value!.membership != null && (_chatController.channel.value!.membership!.channelRole == "channel_member" ||  _chatController.channel.value!.membership!.channelRole == "channel_moderator") &&
                          !_chatController.channel.value!.isMuted ,
                      onChanged: _chatController.channel.value!.membership != null  && (_chatController.channel.value!.membership!.channelRole == "channel_member" ||  _chatController.channel.value!.membership!.channelRole == "channel_moderator") ? (active) async {
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
                      } : null, activeColor: const Color(0xFF00CB7D), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                  )
                ],
              ),
            ),
            Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,),
            _chatController.channel.value?.createdBy?.id != _homeController.id.value ? InkWell(
              onTap: () async {
                await _commonController.getUserById(_chatController.channel.value!.createdBy!.id);
                _navigationController.hideNavBar.value = true;
                pushNewScreen(context, screen: const NestedDetailedChatScreen(create: true)).then((value) => _navigationController.hideNavBar.value = true);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Contact owner", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
              ),
            ) : const SizedBox(),
            _chatController.channel.value?.createdBy?.id != _homeController.id.value ? Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,) : const SizedBox(),
            InkWell(
              onTap: () async {
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Report", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
              ),
            ),
            _chatController.channel.value!.membership == null ? const SizedBox() :Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,),
            _chatController.channel.value!.membership == null ? const SizedBox() : InkWell(
              onTap: () async {
                showDialog(context: context,
                    barrierDismissible: true,
                    builder: (_) =>
                    CupertinoAlertDialog(
                      title: Text("Quit Group", style: TextStyle(fontSize: 16,
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
            _chatController.channel.value?.createdBy?.id == _homeController.id.value ||
                _chatController.channel.value?.membership?.channelRole == "channel_moderator" ? Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,) : const SizedBox(),
            _chatController.channel.value?.createdBy?.id == _homeController.id.value ||
                _chatController.channel.value?.membership?.channelRole == "channel_moderator" ? InkWell(
              onTap: () async {
                showDialog(context: context,
                    barrierDismissible: true,
                    builder: (_) =>
                        CupertinoAlertDialog(
                          title: Text("Delete Group", style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              color: MediaQuery
                                  .of(context)
                                  .platformBrightness == Brightness.dark ? Colors
                                  .white : Colors.black),),
                          content: Text("Are you sure? This action is irreversible",
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
                                if (!_chatController.channel.value!.id!.startsWith(
                                    "!members")) {
                                  await _chatController.deleteInbox(
                                      _chatController.channel.value!.id!);
                                }
                                await _chatController.channel.value!.delete();
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
                child: Text("Delete the group", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
              ),
            ) : const SizedBox(),
          ],
        ),
      )
    ],)
      ,)),);
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
                child: _chatController.isEditingGroup.value ? SizedBox(
                  width: 200,
                  child: TextField(
                    //autofocus: true,
                    maxLines: 1,
                    controller: _nameGroupController,
                    maxLength: 10,
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
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintText: _chatController.channel.value!.extraData['nameOfGroup'] as String),
                  ),
                ) : Text(
                _chatController.channel.value!.extraData['nameOfGroup'] as String,
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
              ), _chatController.isEditingGroup.value ? InkWell(
                onTap: () async {
                  if(_nameGroupController.text.isNotEmpty || !_profileController.urlPictureGroup.value.isNullOrBlank!){
                    if(_profileController.urlPictureGroup.value.isNullOrBlank!){
                      await _chatController.channel.value!.updatePartial(set: {"nameOfGroup": _nameGroupController.text});
                    } else {
                      await _chatController.channel.value!.updatePartial(set: {"nameOfGroup": _nameGroupController.text.isEmpty ? _chatController.channel.value!.extraData['nameOfGroup'] as String : _nameGroupController.text, "picOfGroup": _profileController.urlPictureGroup.value});
                    }
                  }
                  _chatController.isEditingGroup.value = false;
                },
                child: const Padding(
                  padding: EdgeInsets.only(
                      top: 16.0, left: 16),
                  child: Text("DONE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          Color(0xFF00CB7D))),
                ),
              ): IconButton(
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
