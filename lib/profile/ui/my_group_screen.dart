import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';

import '../../global_getx/home/home_controller.dart';

class MyGroupScreen extends StatefulWidget {
  const MyGroupScreen({Key? key}) : super(key: key);

  @override
  State<MyGroupScreen> createState() => _MyGroupScreenState();
}

class _MyGroupScreenState extends State<MyGroupScreen> {

  StreamChannelListController? streamChannelListControllerGroups;
 HomeController get _homeController => Get.find<HomeController>();
  final _chatController = Get.put(ChatsController());
  final utils = Utils();

  StreamChannelListController buildStreamChannelListController(){
    return StreamChannelListController(
      client: StreamChat.of(context).client,
      filter:
      Filter.and([
        Filter.equal('isConv', false),
        Filter.equal("created_by_id", _homeController.id.value),
      ]),
      channelStateSort: const [SortOption('last_message_at')],
      limit: 10,
    );
  }

  @override
  void initState() {
    streamChannelListControllerGroups = buildStreamChannelListController();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
      body: Column(
        children: [
          buildAppbar(context),
          MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Expanded(
                child: SafeArea(
                  minimum: const EdgeInsets.only(top: 16),
                  child: StreamChannelListView(
                    channelSlidableEnabled: false ,
                    channelConv : false,
                    channelFriends: false,
                    channelFav: false,
                    controller: streamChannelListControllerGroups!,
                  onChannelTap: (channel){
                    _chatController.channel.value = channel;
                    pushNewScreen(context, screen: StreamChannel(channel: channel, child: const ChannelPage()));                  },),
                ),
              ))
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
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Text(
                  "My Groups",
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
              ),IconButton(
                  onPressed: () async {
                  },
                  icon:  Icon(Icons.more_vert_outlined, size: 30, color: MediaQuery.of(context)
                      .platformBrightness ==
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
