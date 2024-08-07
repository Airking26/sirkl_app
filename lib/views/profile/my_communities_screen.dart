import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/controllers/chats_controller.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';

import '../../common/view/nav_bar/persistent-tab-view.dart';
import '../../common/view/stream_chat/src/channel/channel_page.dart';
import '../../controllers/home_controller.dart';

class MyCommunityScreen extends StatefulWidget {
  const MyCommunityScreen({Key? key}) : super(key: key);

  @override
  State<MyCommunityScreen> createState() => _MyCommunityScreenState();
}

class _MyCommunityScreenState extends State<MyCommunityScreen> {

  HomeController get _homeController => Get.find<HomeController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  final utils = Utils();

  StreamChannelListController? streamChannelListControllerCommunities;

  @override
  void initState() {
    streamChannelListControllerCommunities = buildStreamChannelListController();
    super.initState();
  }

  StreamChannelListController buildStreamChannelListController(){
    return StreamChannelListController(
      client: StreamChat.of(context).client,
      filter:
      Filter.and([
        Filter.greater("member_count", 2),
        Filter.notExists("isConv"),
        Filter.equal('owner', _homeController.userMe.value.wallet!)
      ]),
      limit: 10,
    );
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
                    emptyBuilder: (context){
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 16),
                        child: Text("Claim the ownership of your communities and it will appear here..", style: TextStyle(fontSize: 18, fontFamily: "Gilroy", fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                      );
                    },
                    controller: streamChannelListControllerCommunities!,
                    onChannelTap: (channel){
                      _chatController.channel.value = channel;
                      pushNewScreen(context, screen: StreamChannel(channel: channel,
                          child: const ChannelPage()));
                      },),
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
                  "My Communities",
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
