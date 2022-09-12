import 'package:flutter/material.dart';

import '../common/view/navbar/floating_navbar.dart';
import '../common/view/navbar/floating_navbar_item.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102437),
      /*appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        toolbarHeight: 120,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular((50)),
          ),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
          //border: Border.all(color: Colors.white, width: 0.2),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF111D28),//.withAlpha(195),
                Color(0xFF1E2032)//.withAlpha(195)
              ]
          ),
        ),
        ),
      ),*/
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        margin: EdgeInsets.zero,
        borderRadius: 0,
        elevation: 5,
        currentIndex: _currentIndex,
        selectedBackgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF00CB7D),
        //backgroundColor: const Color(0xFF111D28),
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
          _currentIndex = val;
        },
      ),
      body: Container(
        height: 150,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(45))
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 0.25),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
            gradient:  LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF111D28),//.withAlpha(195),
                  Color(0xFF1E2032)//.withAlpha(195)
                ]
            ),
          ),
        ),
      ),
    );
  }
}
