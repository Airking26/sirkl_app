// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/chats/ui/nested_detailed_chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/report_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:sirkl/common/constants.dart' as con;


class SettingsProfileElseScreen extends StatefulWidget {
  const SettingsProfileElseScreen({Key? key, required this.fromConversation, required this.fromProfile}) : super(key: key);
  final bool fromConversation;
  final bool fromProfile;

  @override
  State<SettingsProfileElseScreen> createState() => _SettingsProfileElseScreenState();
}

class _SettingsProfileElseScreenState extends State<SettingsProfileElseScreen> {


  final _profileController = Get.put(ProfileController());
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());
  final _callController = Get.put(CallsController());
  final _chatController = Get.put(ChatsController());

  final utils = Utils();

  @override
  void initState() {
    _commonController.checkUserIsInFollowing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
      body: Obx(() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAppbar(context),
            const SizedBox(height: 24,),
            Align(
              alignment: Alignment.center,
              child: ClipOval(
                child: SizedBox.fromSize(
                  size: const Size.fromRadius(70),
                  child: _commonController.userClicked.value!.picture.isNullOrBlank!
                      ? TinyAvatar(
                      baseString: _commonController.userClicked.value!.wallet!,
                      dimension: 140,
                      circular: true,
                      colourScheme: TinyAvatarColourScheme
                          .seascape)
                      : CachedNetworkImage(
                      imageUrl: _commonController.userClicked.value!.picture!,
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
                _commonController.userClickedFollowStatus.value ? const SizedBox() : InkWell(
                  onTap: () async {
                    if( await _commonController.addUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)){
                    utils.showToast(context, con.userAddedToSirklRes.trParams({"user": _commonController.userClicked.value!.userName ?? _commonController.userClicked.value!.wallet!}));
                    }
                  },
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 5 ,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white,),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/add_user.png', color: const Color(0xFF00CB7D), width: 24, height: 24,),
                          const SizedBox(height: 4),
                          const Text("Add", style: TextStyle(fontFamily: "Gilroy", color: Color(0xFF00CB7D)),)
                        ],),
                    ),
                  ),
                ),
                _commonController.userClickedFollowStatus.value ? const SizedBox() : const SizedBox(width: 16,),
                InkWell(
                  onTap: () async {
                    _callController.userCalled.value =
                    _commonController.userClicked.value!;
                    await _callController.inviteCall(
                        _commonController.userClicked.value!,
                        DateTime.now().toString(),
                        _homeController.id.value);
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
                          Image.asset('assets/images/call_tab.png', color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  Colors.white : Colors.black, width: 24, height: 24,),
                          const SizedBox(height: 4),
                          const Text("Call", style: TextStyle(fontFamily: "Gilroy"),)
                        ],),
                    ),
                  ),
                ),
                const SizedBox(width: 16,),
                InkWell(
                  onTap: () async {
                    _commonController.userClicked.value =
                    _commonController.userClicked.value!;
                    _navigationController.hideNavBar.value = true;
                    widget.fromConversation ? Navigator.pop(context) : pushNewScreen(context,
                        screen:
                        const NestedDetailedChatScreen(
                            create: true, fromProfile: true,))
                        .then((value) => _navigationController.hideNavBar.value = true);
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
                          Image.asset('assets/images/chat_tab.png', color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  Colors.white : Colors.black, width: 24, height: 24,),
                          const SizedBox(height: 4),
                          const Text("Message", style: TextStyle(fontFamily: "Gilroy"),)
                        ],),
                    ),
                  ),
                ),
                const SizedBox(width: 16,),
                InkWell(
                  onTap: () async {
                    var uri = await _profileController.createDynamicLink("/profileShared?id=${_commonController.userClicked.value!.id!}");
                    Share.share("Check out this profile on SIRKL ${uri.toString()}");
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
                      widget.fromProfile ? Navigator.pop(context) : pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: false));
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Profile", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                    ),
                  ),
                  Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  InkWell(
                    onTap: (){
                      _profileController.isEditingProfileElse.value = true;
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Edit nickname (only visible by you)", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
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
                            value: _commonController.userClickedFollowStatus.value && !_homeController.userBlocked.value.contains(_commonController.userClicked.value!.id!),
                            onChanged: _commonController.userClickedFollowStatus.value ? (active) async {
                              if(!active) {
                                if(!_homeController.userBlocked.contains(_commonController.userClicked.value!.id!)) {
                                  _homeController.userBlocked.assign(_commonController.userClicked.value!.id!);
                                }
                                await GetStorage().write(con.USER_BLOCKED,
                                    _homeController.userBlocked);
                                await StreamChat
                                    .of(context)
                                    .client
                                    .muteUser(
                                    _commonController.userClicked.value!.id!);
                              }
                              else {
                                _homeController.userBlocked.remove(
                                    _commonController.userClicked.value!.id!);
                                _homeController.refresh();
                                _homeController.userBlocked.refresh();
                                await GetStorage().write(con.USER_BLOCKED,
                                    _homeController.userBlocked);
                                await StreamChat
                                    .of(context)
                                    .client
                                    .unmuteUser(
                                    _commonController.userClicked.value!.id!);
                              }
                          } : null, activeColor: const Color(0xFF00CB7D), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                        )
                      ],
                    ),
                  ),
                  _commonController.userClickedFollowStatus.value ? Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,) : const SizedBox(),
                  _commonController.userClickedFollowStatus.value ? InkWell(
                    onTap: () async {
                      if(await _commonController.removeUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)) {
                        utils.showToast(context, con.userRemovedofSirklRes.trParams({"user": _commonController.userClicked.value!.userName ?? _commonController.userClicked.value!.wallet!}));
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Remove from my SIRKL", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                    ),
                  ) : const SizedBox(),
                  Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  widget.fromConversation ? InkWell(
                    onTap: () async {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => CupertinoAlertDialog(
                            title: Text("Delete Conversation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                            content: Text("Are you sure? This action is irreversible", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                            actions: [
                              CupertinoDialogAction(child: Text("No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)), onPressed: (){
                                Get.back();},),
                              CupertinoDialogAction(child: Text("Yes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)),
                                onPressed: () async {
                                  if(!_chatController.channel.value!.id!.startsWith("!members")) await _chatController.deleteInbox(_chatController.channel.value!.id!);
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
                      child: Text("Delete chat", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                    ),
                  ) : const SizedBox(),
                  widget.fromConversation ? Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,) : const SizedBox(),
                  InkWell(
                    onTap: () async {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => CupertinoAlertDialog(
                            title: Text("Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                            actions: [
                              CupertinoDialogAction(child:Text("Harassment or bullying", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                                onPressed: () async {
                                  await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _commonController.userClicked.value!.id!, description: "Harassment or bullying", type: 0), utils);
                                  Get.back();
                                },),
                              CupertinoDialogAction(child:Text("Hate speech or discrimination", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                                onPressed: () async {
                                  await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _commonController.userClicked.value!.id!, description: "Hate speech or discrimination", type: 0), utils);
                                  Get.back();
                                },),
                              CupertinoDialogAction(child:Text("Explicit or inappropriate content", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                                onPressed: () async {
                                  await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _commonController.userClicked.value!.id!, description: "Explicit or inappropriate content", type: 0), utils);
                                  Get.back();
                                },),
                              CupertinoDialogAction(child:Text("Spam or scams", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                                onPressed: () async {
                                  await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _commonController.userClicked.value!.id!, description: "Spam or scams", type: 0), utils);
                                  Get.back();
                                },),
                              CupertinoDialogAction(child:Text("Privacy violations", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                              onPressed: () async {
                                await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _commonController.userClicked.value!.id!, description: "Privacy violations", type: 0), utils);
                                Get.back();
                                },),
                            ],
                          ));

                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Report", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                    ),
                  ),
                  /*Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  InkWell(
                    onTap: () async {
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Block user", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                    ),
                  ),*/
                  const SizedBox(height: 24,),
                ],
              ),
            )
          ],
        ),
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
                child: Icon(Icons.keyboard_arrow_left_rounded,size: 42,color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child:
                _profileController.isEditingProfileElse.value ?
                SizedBox(
                  width: 200,
                  child: TextField(
                    autofocus: true,
                    maxLines: 1,
                    controller: _profileController.usernameElseTextEditingController.value,
                    maxLength: 10,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintText: ""
                    ),
                  ),
                ):
                Text(
                  _homeController.nicknames[_commonController.userClicked.value!.wallet!] != null ?
                  _homeController.nicknames[_commonController.userClicked.value!.wallet!] + (_commonController.userClicked.value!.userName!.isEmpty ? "" : " (${_commonController.userClicked.value!.userName!})") : (_commonController.userClicked.value!.userName!.isEmpty ? "${_commonController.userClicked.value!.wallet!.substring(0, 6)}...${_commonController.userClicked.value!.wallet!.substring(_commonController.userClicked.value!.wallet!.length - 4)}" : _commonController.userClicked.value!.userName!),
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
              ),
              _profileController.isEditingProfileElse.value ? InkWell(
                onTap: () async {
                  await _profileController.updateMe(UpdateMeDto(nicknames: {_commonController.userClicked.value!.wallet! : _profileController.usernameElseTextEditingController.value.text}), StreamChat.of(context).client);
                  _homeController.updateNickname(_commonController.userClicked.value!.wallet!, _profileController.usernameElseTextEditingController.value.text);
                  _profileController.isEditingProfileElse.value = false;
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16),
                  child: Text("DONE", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Gilroy', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00CB7D))),
                ),
              ) :
              IconButton(
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
