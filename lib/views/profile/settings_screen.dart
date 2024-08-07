// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sirkl/common/enums/pdf_type.dart';
import 'package:sirkl/common/save_pref_keys.dart';
import 'package:restart/restart.dart';
import 'package:sirkl/config/s_config.dart';

import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';

import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/controllers/wallet_connect_modal_controller.dart';
import 'package:sirkl/repo/google_repo.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../config/s_colors.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../views/home/pdf_screen.dart';
import '../chats/detailed_chat_screen.dart';
import '../home/home_screen.dart';
import 'my_communities_screen.dart';
import 'my_group_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  final box = GetStorage();
  YYDialog dialogMenu = YYDialog();

  ProfileController get _profileController => Get.find<ProfileController>();  
  HomeController get _homeController => Get.find<HomeController>();
  CommonController get _commonController => Get.find<CommonController>();
  NavigationController get _navigationController => Get.find<NavigationController>();
  WalletConnectModalController get _walletConnectModalController => Get.find<WalletConnectModalController>();

  @override
  void initState() {
    seedPhrase.value = box.read(SharedPref.SEED_PHRASE);
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
                           0.0),
                      fit: BoxFit.cover,
                      colorBlendMode:
                      BlendMode.difference,
                      placeholder: (context, url) =>
                       Center(
                          child: CircularProgressIndicator(
                              color: SColors.activeColor)),
                      errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png"))),
                ),
            ),
            const SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    _profileController.isEditingProfile.value = true;
                    Navigator.pop(context, {"name" : _homeController.userMe.value.userName});
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
                        const Text("Edit", style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500),)
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
                        const Text("Share", style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500),)
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
                  InkWell(
                    onTap: (){
                      pushNewScreen(context, screen: const MyGroupScreen());
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("My groups", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                    ),
                  ),
                  Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  InkWell(
                    onTap: (){
                      pushNewScreen(context, screen: const MyCommunityScreen());
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("My Communities", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                    ),
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
                          }, activeColor: SColors.activeColor, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                        )
                      ],
                    ),
                  ),
                  Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white : Colors.black,),
                  seedPhrase.value == null ? const SizedBox() : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async  => await promptChoseBackupMethod(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Save my SIRKL wallet", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500, color: Colors.redAccent),),
                        ),
                      ),
                      Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                          ? Colors.white : Colors.black,),
                    ],
                  ),
                  _homeController.userMe.value.userName == null || _homeController.userMe.value.userName!.isEmpty ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async => await _profileController.promptClaimUsername(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Claim your username", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                        ),
                      ),
                      Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                          ? Colors.white : Colors.black,),
                    ],
                  ) : const SizedBox(),
                  InkWell(
                    onTap: () async {
                      if(!_profileController.contactUsClicked.value) {
                        _profileController.contactUsClicked.value = true;
                        await _commonController.getUserById(SConfig.SIRKL_ID);
                        await pushNewScreen(context,
                            screen: const DetailedChatScreen(create: true)).then((value) => _profileController.contactUsClicked.value = false);
                      }
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
                        showDialog(context: context,
                          barrierDismissible: true,
                          builder: (_) => CupertinoAlertDialog(
                            title: Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                            content: Text("Are you sure? This action is irreversible", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                            actions: [
                              CupertinoDialogAction(child: Text("No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)), onPressed: (){ Get.back();},),
                              CupertinoDialogAction(child: Text("Yes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)),
                                onPressed: () async {
                                  await StreamChat.of(context).client.disconnectUser();
                                  await GetStorage().erase();
                                  _homeController.id.value = "";
                                  _homeController.isConfiguring.value = false;
                                  _homeController.accessToken.value = "";
                                  _homeController.address.value = "";
                                  _navigationController.controller.value.jumpToTab(0);
                                  _navigationController.hideNavBar.value = true;
                                  _walletConnectModalController.w3mService.value?.disconnect();
                                  Get.back();
                                  Get.deleteAll(force: true);
                                  Get.offAll(const HomeScreen());
                                  restart();
                                },)
                            ],
                          )).then((value) {
                            _navigationController.hideNavBar.value = true;
                             Get.back();
                          });
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
        padding: const EdgeInsets.only(top: 24.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){Navigator.pop(context);},
                child: Icon(Icons.keyboard_arrow_left_rounded,size: 42,color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
              Text(
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
              IconButton(
                  onPressed: () async {
                    dialogMenu = dialogPopMenu(context);
                  },
                  icon:  Icon(Icons.more_vert_outlined, size: 32, color: MediaQuery.of(context)
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
              screen: const PDFScreen(pdfType: PDFType.all,));
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
                      await _profileController.deleteUser(_homeController.id.value);
                      await GetStorage().erase();
                      _homeController.accessToken.value = "";
                      _homeController.address.value = "";
                      _navigationController.controller.value.jumpToTab(0);
                      Get.back();
                      Navigator.pop(context);
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
