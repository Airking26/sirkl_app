import 'package:flutter/material.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF102437),
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
        ));  }
}
