import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../calls/ui/calls_screen.dart';
import '../../chats/ui/chats_screen.dart';
import '../../common/view/navbar/floating_navbar.dart';
import '../../common/view/navbar/floating_navbar_item.dart';
import '../../groups/ui/groups_screen.dart';
import '../../home/ui/home_screen.dart';
import '../../profile/ui/profile_screen.dart';
import '../controller/navigation_controller.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  final _navigationController = Get.put(NavigationController());
  final List<Widget> _pages = [
    const HomeScreen(),
    const CallsScreen(),
    const GroupsScreen(),
    const ChatsScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xFF102437),
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        margin: EdgeInsets.zero,
        borderRadius: 0,
        elevation: 5,
        currentIndex: _navigationController.currentPage.value,
        selectedBackgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF00CB7D),
        padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
        topMarginText: 0,
        items: [
          FloatingNavbarItem(icon: "assets/images/home-6-fill@3x.png", title: 'Home'),
          FloatingNavbarItem(icon: "assets/images/phone-fill@3x.png", title: 'Calls'),
          FloatingNavbarItem(icon: "assets/images/group-fill@3x.png", title: 'Groups'),
          FloatingNavbarItem(icon: "assets/images/chat-1-fill@3x.png", title: 'Chats'),
          FloatingNavbarItem(icon: "assets/images/user-6-fill@3x.png", title: 'Profile'),
        ],
        onTap: (int val){
          setState((){
            _navigationController.changeCurrentPage(val);
            _navigationController.pageController.value.jumpToPage(val);
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
