import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/controllers/call_controller.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/home_controller.dart';

import '../../controllers/navigation_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../views/calls/calls_screen.dart';
import '../../views/chats/chat_screen.dart';
import '../../views/group/groups_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/profile/profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  NavigationController get _navigationController =>
      Get.find<NavigationController>();
  CallController get _callController => Get.find<CallController>();
  CommonController get _commonController => Get.find<CommonController>();
  HomeController get _homeController => Get.find<HomeController>();
  ProfileController get _profileController => Get.find<ProfileController>();

  late final List<Widget> _pages = [
    const HomeScreen(),
    const CallsScreen(),
    const GroupsScreen(),
    const ChatScreen(),
    const ProfileScreen()
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
          icon: const ImageIcon(
            AssetImage("assets/images/home_tab.png"),
            size: 18,
          ),
          title: (con.homeTabRes.tr),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),
      PersistentBottomNavBarItem(
          icon: const ImageIcon(
            AssetImage("assets/images/call_tab.png"),
            size: 18,
          ),
          title: (con.callsTabRes.tr),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),
      PersistentBottomNavBarItem(
          icon: const ImageIcon(
            AssetImage("assets/images/group-tab.png"),
            size: 18,
          ),
          title: (con.groupsTabRes.tr),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),
      PersistentBottomNavBarItem(
          icon: const ImageIcon(
            AssetImage("assets/images/chat_tab.png"),
            size: 18,
          ),
          title: (con.chatsTabRes.tr),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),
      PersistentBottomNavBarItem(
          icon: const ImageIcon(
            AssetImage("assets/images/profile_tab.png"),
            size: 18,
          ),
          title: (con.profileTabRes.tr),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),
    ];
  }

  @override
  void initState() {
    _navigationController.controller.value.index =
        _homeController.accessToken.value.isNullOrBlank! ? 0 : 4;
    if (_homeController.accessToken.value.isNotEmpty) {
      _navigationController.hideNavBar.value = false;
    } else {
      _navigationController.hideNavBar.value = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
            body: PersistentTabView(
          context,
          screens: _pages,
          hideNavigationBar: _navigationController.hideNavBar.value,
          controller: _navigationController.controller.value,
          items: _navBarsItems(),
          confineInSafeArea: !_navigationController.hideNavBar.value,
          handleAndroidBackButtonPress: true,
          decoration: NavBarDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color(0xFF111D28)
                      : Colors.white,
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color(0xFF1E2032)
                      : Colors.white
                ]),
          ),
          resizeToAvoidBottomInset: true,
          hideNavigationBarWhenKeyboardShows: true,
          popAllScreensOnTapOfSelectedTab: true,
          navBarStyle: NavBarStyle.simple,
          onItemSelected: (index) async {
            Navigator.popUntil(context, (route) => route.isFirst);
            if (index == 0) {
              _profileController.isEditingProfile.value = false;
              if (_homeController.accessToken.value.isNotEmpty) {
                _commonController.gettingStoryAndContacts.value = true;
                _homeController.loadingStories.value = true;
                _homeController.pageKey.value = 0;
                _homeController.storyPagingController.value.refresh();
                _commonController.showSirklUsers(_homeController.id.value);
              }
            } else if (index == 1) {
              _profileController.isEditingProfile.value = false;
              if (_homeController.accessToken.value.isEmpty ||
                  _homeController.isConfiguring.value) {
                _navigationController.controller.value.index = 0;
              } else {
                _callController.pageKey.value = 0;
                _callController.pagingController.value.refresh();
              }
            } else if (index == 2) {
              _profileController.isEditingProfile.value = false;
              if (_homeController.accessToken.value.isEmpty ||
                  _homeController.isConfiguring.value) {
                _navigationController.controller.value.index = 0;
              }
            } else if (index == 3) {
              _profileController.isEditingProfile.value = false;
              if (_homeController.accessToken.value.isEmpty ||
                  _homeController.isConfiguring.value) {
                _navigationController.controller.value.index = 0;
              }
            } else if (index == 4) {
              _homeController.checkOfflineNotificationAndRegister();
              _profileController
                  .checkIfHasUnreadNotification(_homeController.id.value);
              if (_homeController.accessToken.value.isEmpty ||
                  _homeController.isConfiguring.value) {
                _navigationController.controller.value.index = 0;
              } else if (_homeController.displayPopupFirstConnection.value) {
                _profileController.promptClaimUsername(context).then((v) =>
                    _homeController.displayPopupFirstConnection.value = false);
                /*showCupertinoDialog(context: context, barrierDismissible: false, builder: (context) {
                  return Obx(() => CupertinoAlertDialog(
                    title: const Text("Welcome new user!"), content: const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 24, right: 24),
                    child: Text("To receive your SIRKL pass sbt in your wallet, please mint it, it is totally free.",
                      style: TextStyle(fontSize: 15),),
                  ), actions: [
                    TextButton(onPressed: (){
                      _homeController.displayPopupFirstConnection.value = false;
                      Get.back();
                      }, child: Text("Later", style: TextStyle(color: SColors.activeColor))),
                    TextButton(onPressed: () async {
                      _homeController.displayPopupFirstConnection.value = false;
                      _web3Controller.isMintingInProgress.value = true;
                      var connector = await _web3Controller.connect();
                      connector.onSessionConnect.subscribe((args) async {
                        await _web3Controller.mintMethod(context, connector, args, _homeController.userMe.value.wallet!);
                      });
                    }, child: _web3Controller.isMintingInProgress.value ? Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: SColors.activeColor)),) : Text("MINT", style: TextStyle(color: SColors.activeColor),))
                  ],));
                });*/
              } else {
                AppsflyerSdk appsflyerSdk = Get.find<AppsflyerSdk>();
                appsflyerSdk.logEvent("click_profile", {
                  "user_id": _homeController.id.value,
                  "user_wallet": _homeController.userMe.value.wallet
                });
              }
            }
          },
        )));
  }
}
