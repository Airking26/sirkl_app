import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/global_getx/calls/calls_controller.dart';


import 'package:sirkl/global_getx/common/common_controller.dart';
import 'package:sirkl/global_getx/web3/web3_controller.dart';
import '../../config/s_colors.dart';
import '../../global_getx/home/home_controller.dart';
import '../../global_getx/profile/profile_controller.dart';


import '../../global_getx/navigation/navigation_controller.dart';
import 'package:sirkl/common/constants.dart' as con;

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

  NavigationController get _navigationController => Get.find<NavigationController>();
  CallsController get _callController => Get.find<CallsController>();
  CommonController get _commonController => Get.find<CommonController>();
  HomeController get _homeController => Get.find<HomeController>();
  ProfileController get _profileController => Get.find<ProfileController>();
  Web3Controller get _web3Controller => Get.find<Web3Controller>();


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
        icon: const ImageIcon(AssetImage("assets/images/home_tab.png"), size: 18,),
        title: (con.homeTabRes.tr),
        activeColorPrimary: SColors.activeColor,
        inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)

      ),
      PersistentBottomNavBarItem(
        icon: const ImageIcon(AssetImage("assets/images/call_tab.png"), size: 18,),
        title: (con.callsTabRes.tr),
        activeColorPrimary: SColors.activeColor,
        inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)

      ),
      PersistentBottomNavBarItem(
        icon: const ImageIcon(AssetImage("assets/images/group-tab.png"), size: 18,),
        title: (con.groupsTabRes.tr),
        activeColorPrimary: SColors.activeColor,
        inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)

      ),
      PersistentBottomNavBarItem(
        icon: const ImageIcon(AssetImage("assets/images/chat_tab.png"), size: 18,),
        title: (con.chatsTabRes.tr),
        activeColorPrimary: SColors.activeColor,
        inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)
      ),
      PersistentBottomNavBarItem(
        icon: const ImageIcon(AssetImage("assets/images/profile_tab.png"), size: 18,),
        title: (con.profileTabRes.tr),
        activeColorPrimary: SColors.activeColor,
        inactiveColorPrimary: const Color(0xFF9BA0A5),
        textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)
      ),

    ];
  }

  @override
  void initState() {
    _navigationController.controller.value.index = _homeController.accessToken.value.isNullOrBlank! ? 0 : 4;
    if(_homeController.accessToken.value.isNotEmpty) {
      _navigationController.hideNavBar.value = false;
    } else {
      _navigationController.hideNavBar.value = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() =>Scaffold(
        body: PersistentTabView(
          context,
          screens: _pages,
          hideNavigationBar: _navigationController.hideNavBar.value,
          controller: _navigationController.controller.value,
          items: _navBarsItems(),
          confineInSafeArea: true,
          handleAndroidBackButtonPress: true,
          decoration: NavBarDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF111D28) : Colors.white,
                MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032): Colors.white
              ]
          ),),
          resizeToAvoidBottomInset: true,
          hideNavigationBarWhenKeyboardShows: true,
          popAllScreensOnTapOfSelectedTab: true,
          navBarStyle: NavBarStyle.simple,
          onItemSelected: (index) async{
            Navigator.popUntil(context, (route) => route.isFirst);
            if(index == 0) {
              _profileController.isEditingProfile.value = false;
              if(_homeController.accessToken.value.isNotEmpty) {
                _commonController.gettingStoryAndContacts.value = true;
                _homeController.loadingStories.value = true;
                _homeController.pageKey.value = 0;
                _homeController.pagingController.value.refresh();
                _commonController.showSirklUsers(_homeController.id.value);
              }
            } else if(index == 1) {
              _profileController.isEditingProfile.value = false;
              if(_homeController.accessToken.value.isEmpty || _homeController.isConfiguring.value){
                _navigationController.controller.value.index = 0;
              } else {
                _callController.pageKey.value = 0;
                _callController.pagingController.value.refresh();
              }
            } else if(index == 2){
              _profileController.isEditingProfile.value = false;
              if(_homeController.accessToken.value.isEmpty || _homeController.isConfiguring.value){
                _navigationController.controller.value.index = 0;
              }
            } else if(index == 3){
              _profileController.isEditingProfile.value = false;
              if(_homeController.accessToken.value.isEmpty || _homeController.isConfiguring.value){
                _navigationController.controller.value.index = 0;
              }
            } else if(index == 4){
              _homeController.checkOfflineNotifAndRegister();
              _profileController.checkIfHasUnreadNotif(_homeController.id.value);
              if(_homeController.accessToken.value.isEmpty || _homeController.isConfiguring.value){
                _navigationController.controller.value.index = 0;
              } else if(_homeController.mint.value){
                showCupertinoDialog(context: context, barrierDismissible: false, builder: (context) {
                  return Obx(() => CupertinoAlertDialog(
                    title: const Text("Welcome new user!"), content: const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 24, right: 24),
                    child: Text("To receive your SIRKL pass sbt in your wallet, please mint it, it is totally free.",
                      style: TextStyle(fontSize: 15),),
                  ), actions: [
                    TextButton(onPressed: (){
                      _homeController.mint.value = false;
                      Get.back();
                      }, child: Text("Later", style: TextStyle(color: SColors.activeColor))),
                    TextButton(onPressed: () async {
                      _homeController.mint.value = false;
                      _web3Controller.isMintingInProgress.value = true;
                      var connector = await _web3Controller.connect();
                      connector.onSessionConnect.subscribe((args) async {
                        await _web3Controller.mintMethod(connector, args, _homeController.userMe.value.wallet!);
                      });
                    }, child: _web3Controller.isMintingInProgress.value ? Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: SColors.activeColor)),) : Text("MINT", style: TextStyle(color: SColors.activeColor),))
                  ],));
                });

              }
            }
          },
        )
    ));
  }
}
