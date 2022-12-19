import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoryCreatorScreen extends StatefulWidget {
  const StoryCreatorScreen({Key? key}) : super(key: key);

  @override
  State<StoryCreatorScreen> createState() => _StoryCreatorScreenState();
}

class _StoryCreatorScreenState extends State<StoryCreatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
      resizeToAvoidBottomInset: false,
      body: Center(),
    );
  }
}
