
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/model/request_to_join_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

class RequestWaitingForApprovalScreen extends StatefulWidget {
  const RequestWaitingForApprovalScreen({Key? key}) : super(key: key);

  @override
  State<RequestWaitingForApprovalScreen> createState() => _RequestWaitingForApprovalScreenState();
}

class _RequestWaitingForApprovalScreenState extends State<RequestWaitingForApprovalScreen> {

  final _homeController = Get.put(HomeController());
  final _chatController = Get.put(ChatsController());
  final utils = Utils();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
    body: Obx(() => Column(
      children: [
        buildAppbar(context),
        Expanded(child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
            child: ListView.builder(
              itemCount: _chatController.requestsWaiting.length,
                itemBuilder: (context, index){
                return buildNotificationTile(context, _chatController.requestsWaiting[index], index);
                }),
          ),
        ))
      ],
    )),);
  }

  Widget buildNotificationTile(BuildContext context, UserDTO item, int index){
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
        child: ListTile(
          onTap: () async{
            //await _commonController.getUserById(item.idData);
            //pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: false));
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () async {
                if(await _chatController.acceptDeclineRequest(RequestToJoinDto(receiver: _homeController.id.value, requester: item.id, channelName: _chatController.channel.value!.extraData["nameOfGroup"] as String, channelId: _chatController.channel.value!.id!, accept: true))){
                  _chatController.requestsWaiting.removeWhere((element) => element.id == item.id);
                  _chatController.requestsWaiting.refresh();
                  if(_chatController.requestsWaiting.isEmpty) Navigator.pop(context);
                }
              }, icon: const Icon(Icons.add, color: Color(0xff00CB7D),)),
              IconButton(onPressed: () async {
                if(await _chatController.acceptDeclineRequest(RequestToJoinDto(receiver: _homeController.id.value, requester: item.id, channelName: _chatController.channel.value!.extraData["nameOfGroup"] as String, channelId: _chatController.channel.value!.id!, accept: false))){
                  _chatController.requestsWaiting.removeWhere((element) => element.id == item.id);
                  _chatController.requestsWaiting.refresh();
                  if(_chatController.requestsWaiting.isEmpty) Navigator.pop(context);
                }
              }, icon: const Icon(Icons.close_rounded, color: Colors.grey,))
            ],),
          leading:
          item.picture.isNullOrBlank! ?
          SizedBox(height: 50, width: 50, child: TinyAvatar(baseString: item.wallet?? "", dimension: 50, circular: true, colourScheme:TinyAvatarColourScheme.seascape )) :
          ClipRRect(
            borderRadius: BorderRadius.circular(90),
            child: CachedNetworkImage(imageUrl: item.picture!, width: 50, height: 50, fit: BoxFit.cover,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png", width: 50, height: 50, fit: BoxFit.cover)),
          ),
          title: Transform.translate(
            offset: Offset(item.picture.isNullOrBlank! ? 0 : -8, 0),
            child: Text(_homeController.nicknames[item.wallet!] != null ?
            _homeController.nicknames[item.wallet!] + (item.userName!.isEmpty ? "" : " (${item.userName!})") : "${item.userName!.isEmpty ? "${item.wallet!.substring(0, 6)}...${item.wallet!.substring(item.wallet!.length - 4)}" : item.userName!} has requested to join ${_chatController.channel.value!.extraData['nameOfGroup'] as String}", style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color:MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black.withOpacity(0.6))),
          ),
          //subtitle: Text("Lorem Ipsum is simply...", style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Get.isDarkMode ? Color(0xFF9BA0A5) : Color(0xFF828282))),
        ),
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
        padding: const EdgeInsets.only(top: 12.0),
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
                  "Waiting for approval",
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
