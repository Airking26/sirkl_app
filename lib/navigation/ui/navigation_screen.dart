import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/calls/ui/calls_screen.dart';
import 'package:sirkl/chats/ui/chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import '../../groups/ui/groups_screen.dart';
import '../../home/ui/home_screen.dart';
import '../../profile/ui/profile_screen.dart';
import '../controller/navigation_controller.dart';
import 'package:sirkl/common/constants.dart' as con;

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  final _navigationController = Get.put(NavigationController());
  final _callController = Get.put(CallsController());
  final _commonController = Get.put(CommonController());
  final _homeController = Get.put(HomeController());


  final List<Widget> _pages = [
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
        activeColorPrimary: const Color(0xFF00CB7D),
        inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 12)

      ),
      PersistentBottomNavBarItem(
        icon: const ImageIcon(AssetImage("assets/images/call_tab.png"), size: 18,),
        title: (con.callsTabRes.tr),
        activeColorPrimary: const Color(0xFF00CB7D),
        inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 12)

      ),
      PersistentBottomNavBarItem(
        icon: const ImageIcon(AssetImage("assets/images/group-tab.png"), size: 18,),
        title: (con.groupsTabRes.tr),
        activeColorPrimary: const Color(0xFF00CB7D),
        inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 12)

      ),
      PersistentBottomNavBarItem(
        icon: const ImageIcon(AssetImage("assets/images/chat_tab.png"), size: 18,),
        title: (con.chatsTabRes.tr),
        activeColorPrimary: const Color(0xFF00CB7D),
        inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 12)
      ),
      PersistentBottomNavBarItem(
        icon: const ImageIcon(AssetImage("assets/images/profile_tab.png"), size: 18,),
        title: (con.profileTabRes.tr),
        activeColorPrimary: const Color(0xFF00CB7D),
        inactiveColorPrimary: const Color(0xFF9BA0A5),
        textStyle: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 12)
      ),

    ];
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
          navBarStyle: NavBarStyle.style3,
          onItemSelected: (index){
            if(index == 0) {
              if(_homeController.accessToken.value.isNotEmpty) {
                _commonController.gettingStoryAndContacts.value = true;
                _homeController.loadingStories.value = true;
                _homeController.pageKey.value = 0;
                _homeController.pagingController.value.refresh();
                _commonController.showSirklUsers(_homeController.id.value);
              }
            } else if(index == 1) {
              if(_homeController.accessToken.value.isEmpty || _homeController.isConfiguring.value){
                _navigationController.controller.value.index = 0;
              } else {
                _callController.pageKey.value = 0;
                _callController.pagingController.value.refresh();
              }
            } else if(index == 2){
              if(_homeController.accessToken.value.isEmpty || _homeController.isConfiguring.value){
                _navigationController.controller.value.index = 0;
              }
            } else if(index == 3){
              if(_homeController.accessToken.value.isEmpty || _homeController.isConfiguring.value){
                _navigationController.controller.value.index = 0;
              }
            } else if(index == 4){
              if(_homeController.accessToken.value.isEmpty || _homeController.isConfiguring.value){
                _navigationController.controller.value.index = 0;
              }
            }
          },
        )
    ));
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : Colors.white,
      extendBody: false,
      bottomNavigationBar:
      FloatingNavbar(
        margin: EdgeInsets.zero,
        borderRadius: 0,
        elevation: 0,
        currentIndex: _navigationController.currentPage.value,
        selectedBackgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF00CB7D),
        padding: EdgeInsets.only(top: 8, bottom: Platform.isAndroid ? 16 :  0, left: 8, right: 8),
        topMarginText: 0,
        items: [
          FloatingNavbarItem(icon: "assets/images/home_tab.png", title: con.homeTabRes.tr),
          FloatingNavbarItem(icon: "assets/images/call_tab.png", title: con.callsTabRes.tr),
          FloatingNavbarItem(icon: "assets/images/group-tab.png", title: con.groupsTabRes.tr),
          FloatingNavbarItem(icon: "assets/images/chat_tab.png", title: con.chatsTabRes.tr),
          FloatingNavbarItem(icon: "assets/images/profile_tab.png", title: con.profileTabRes.tr),
        ],
        onTap: (int val){
          setState((){
            if(_homeController.accessToken.isNotEmpty) {
              _navigationController.changeCurrentPage(val);
              _navigationController.pageController.value.jumpToPage(val);
            }
          });
        },
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _navigationController.pageController.value,
        children: _pages,
      )
    );
  }*/
}
