import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/chats/ui/chat_screen.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import '../../calls/ui/calls_screen.dart';
import '../../common/view/navbar/floating_navbar.dart';
import '../../common/view/navbar/floating_navbar_item.dart';
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
  final _homeController = Get.put(HomeController());
  final List<Widget> _pages = [
    const HomeScreen(),
    const CallsScreen(),
    const GroupsScreen(),
    const ChatScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        margin: EdgeInsets.zero,
        borderRadius: 0,
        elevation: 10,
        currentIndex: _navigationController.currentPage.value,
        selectedBackgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF00CB7D),
        padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
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
  }
}
