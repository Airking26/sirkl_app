import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/controllers/inbox_controller.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

import '../../config/s_colors.dart';

class PinnedMessageScreen extends StatefulWidget {
  const PinnedMessageScreen({Key? key}) : super(key: key);

  @override
  State<PinnedMessageScreen> createState() => _PinnedMessageScreenState();
}

class _PinnedMessageScreenState extends State<PinnedMessageScreen> {
  InboxController get _chatController => Get.find<InboxController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xFF102437)
              : const Color.fromARGB(255, 247, 253, 255),
      body: Column(
        children: [
          buildAppbar(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount:
                  _chatController.channel.value!.state!.pinnedMessages.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Colors.white.withOpacity(0.1)
                            : SColors.activeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            _chatController.channel.value!.state!
                                .pinnedMessages[index].text!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                fontFamily: "Gilroy"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              Jiffy(_chatController.channel.value!.state!
                                      .pinnedMessages[index].pinnedAt
                                      ?.toLocal())
                                  .yMMMMEEEEdjm,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  fontFamily: "Gilroy"),
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ));
              },
            ),
          ),
        ],
      ),
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
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF113751)
                  : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF1E2032)
                  : Colors.white
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
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  size: 42,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  "Pinned Messages",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w600,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              IconButton(
                  onPressed: () async {},
                  icon: Icon(Icons.more_vert_outlined,
                      size: 30,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.transparent
                          : Colors.transparent))
            ],
          ),
        ),
      ),
    );
  }
}
