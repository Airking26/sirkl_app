// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/home/ui/pdf_screen.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:tiny_avatar/tiny_avatar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  YYDialog dialogMenu = YYDialog();

  final _profileController = Get.put(ProfileController());
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());

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
            GestureDetector(
                onTap: () async {
                  if (_profileController
                      .isEditingProfile.value) {
                    await _profileController.getImageForProfile();
                  }
                },
                child:
                Align(
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: SizedBox.fromSize(
                        size: const Size.fromRadius(70),
                        child: _profileController.urlPicture.value.isEmpty
                          ? TinyAvatar(
                          baseString: _homeController
                              .userMe.value.wallet!,
                          dimension: 140,
                          circular: true,
                          colourScheme: TinyAvatarColourScheme
                              .seascape)
                          : CachedNetworkImage(
                          imageUrl: _profileController
                              .urlPicture.value,
                          color: Colors.white.withOpacity(
                              _profileController
                                  .isEditingProfile
                                  .value
                                  ? 0.2
                                  : 0.0),
                          fit: BoxFit.cover,
                          colorBlendMode:
                          BlendMode.difference,
                          placeholder: (context, url) =>
                          const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xff00CB7D))),
                          errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png"))),
                    ),
                ),
                ),
            const SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    _profileController.isEditingProfile.value = true;
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
                        Icon(Icons.edit_rounded, color : MediaQuery.of(context).platformBrightness == Brightness.dark ?  Colors.white : Colors.black),
                        const SizedBox(height: 4),
                        const Text("Edit", style: TextStyle(fontFamily: "Gilroy"),)
                      ],),
                    ),
                  ),
                ),
                const SizedBox(width: 16,),
                InkWell(
                  onTap: () async {
                    var uri = await _profileController.createDynamicLink("/profileShared?id=${_homeController.id.value}");
                    Share.share("Check out my profile on SIRKL ${uri.toString()}");
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
            const SizedBox(height: 32,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("My groups", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                  ),
                  Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("My Communities", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                  ),
                  Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Blocked users", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                  ),
                  Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("App notifications", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                        SizedBox(
                          height: 20,
                          child: Switch(value: _homeController.notificationActive.value, onChanged: (active) async {
                            if(!active) {
                              await StreamChat.of(context).client.removeDevice(_homeController.userMe.value.fcmToken!);
                            } else {
                              await StreamChat.of(context).client.addDevice(_homeController.userMe.value.fcmToken!, PushProvider.firebase, pushProviderName: "Firebase_Config");
                            }
                            _homeController.switchActiveNotification(active);
                          }, activeColor: const Color(0xFF00CB7D), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                        )
                      ],
                    ),
                  ),
                  Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  InkWell(
                    onTap: () async {
                      await _commonController.getUserById("63f78a6188f7d4001f68699a");
                      pushNewScreen(context, screen: const DetailedChatScreen(create: true));
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Contact us", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                    ),
                  ),
                  Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  InkWell(
                    onTap: () async {
                      await GetStorage().erase();
                      await StreamChat.of(context).client.disconnectUser();
                      _homeController.accessToken.value = "";
                      _navigationController.controller.value.jumpToTab(0);
                      _navigationController.hideNavBar.value = true;
                      await _profileController.deleteUser(_homeController.id.value);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Logout", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                    ),
                  ),
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
                child: _profileController
                    .isEditingProfile.value
                    ? SizedBox(
                  width: 200,
                  child: TextField(
                    //autofocus: true,
                    maxLines: 1,
                    controller: _profileController
                        .usernameTextEditingController
                        .value,
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
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintText: ""),
                  ),
                )
                    : Text(
                  _homeController.userMe.value.userName!
                      .isEmpty ||
                      _homeController.userMe.value
                          .userName ==
                          _homeController
                              .userMe.value.wallet
                      ? "${_homeController.userMe.value.wallet!.substring(0, 6)}...${_homeController.userMe.value.wallet!.substring(_homeController.userMe.value.wallet!.length - 4)}"
                      : _homeController
                      .userMe.value.userName!,
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
              _profileController.isLoadingPicture.value
                  ? Container(
                  padding: const EdgeInsets.all(8),
                  width: 48,
                  height: 48,
                  child: const CircularProgressIndicator(
                    color: Color(0xFF00CB7D),
                  )) :
              _profileController.isEditingProfile.value
                  ? InkWell(
                onTap: () {
                  _profileController.updateMe(
                      UpdateMeDto(
                          userName: _profileController
                              .usernameTextEditingController
                              .value
                              .text
                              .isEmpty
                              ? "${_homeController
                              .userMe
                              .value
                              .wallet!.substring(0, 6)}...${_homeController.userMe.value.wallet!.substring(_homeController.userMe.value.wallet!.length - 4)}"
                              : _profileController
                              .usernameTextEditingController
                              .value
                              .text,
                          description: _profileController
                              .descriptionTextEditingController
                              .value
                              .text
                              .isEmpty
                              ? ""
                              : _profileController
                              .descriptionTextEditingController
                              .value
                              .text,
                          picture:
                          _profileController
                              .urlPicture
                              .value),
                      StreamChat.of(context)
                          .client);
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
              ) :
              IconButton(
                  onPressed: () async {
                    dialogMenu = dialogPopMenu(context);
                  },
                  icon:  Icon(Icons.more_vert_outlined, size: 30, color: MediaQuery.of(context)
                      .platformBrightness ==
                      Brightness.dark
                      ? Colors.white
                      : Colors.black))
            ],
          ),
        ),
      ),
    );
  }

  YYDialog dialogPopMenu(BuildContext context) {
    return YYDialog().build(context)
      ..width = 175
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor =
      MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.transparent
          : Colors.black.withOpacity(0.05)
      ..backgroundColor =
      MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF1E3244).withOpacity(0.95)
          : Colors.white.withOpacity(0.95)
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: () {
          dialogMenu.dismiss();
          pushNewScreen(context,
              screen: const PDFScreen(isTermsAndConditions: 2));
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                con.legalRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: MediaQuery.of(context).platformBrightness ==
                        Brightness.dark
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () async {
          dialogMenu.dismiss();
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => CupertinoAlertDialog(
                title: Text(
                  "Delete Account",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                          ? Colors.white
                          : Colors.black),
                ),
                content: Text("Are you sure? You will lost all your data.",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Gilroy",
                        color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5))),
                actions: [
                  CupertinoDialogAction(
                    child: Text("No",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Gilroy",
                            color:
                            MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                                ? Colors.white
                                : Colors.black)),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text("Yes",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Gilroy",
                            color:
                            MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                                ? Colors.white
                                : Colors.black)),
                    onPressed: () async {
                      await StreamChat.of(context).client.disconnectUser();
                      await _profileController
                          .deleteUser(_homeController.id.value);
                      await GetStorage().erase();
                      _homeController.accessToken.value = "";
                      _navigationController.controller.value.jumpToTab(0);
                      Get.back();
                    },
                  )
                ],
              ));
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "• Delete account",
                style: TextStyle(
                    fontSize: 14,
                    color: MediaQuery.of(context).platformBrightness ==
                        Brightness.dark
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