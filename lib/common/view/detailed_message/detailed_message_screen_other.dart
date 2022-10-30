import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:zego_zim/zego_zim.dart';

import '../../interface/ZIMEventHandlerManager.dart';
import '../../utils.dart';

class DetailedMessageScreenOther extends StatefulWidget {
  const DetailedMessageScreenOther({Key? key}) : super(key: key);

  @override
  State<DetailedMessageScreenOther> createState() => _DetailedMessageScreenOtherState();
}

class _DetailedMessageScreenOtherState extends State<DetailedMessageScreenOther> {

  final _commonController = Get.put(CommonController());
  final _chatController = Get.put(ChatsController());
  final _homeController = Get.put(HomeController());
  final _textMessageController = TextEditingController();
  final _navController = Get.put(NavigationController());
  static var pageKey = 0;

  @override
  void initState() {
    clearUnReadMessage();
    ZIMEventHandlerManager.loadingEventHandler(_chatController);
    _chatController.chatPagingController.value.addPageRequestListener((pageKey) {
      fetchPage();
    });
    super.initState();
  }

  Future<void> fetchPage() async {
    try {
      List<ZIMMessage> newItems = await _chatController.retrieveMessages(_commonController.userClicked.value == null ? _chatController.conv.value.conversationID : _commonController.userClicked.value!.id!);
      final isLastPage = newItems.length < 50;
      if (isLastPage) {
        _chatController.chatPagingController.value.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey++;
        _chatController.chatPagingController.value.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _chatController.chatPagingController.value.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
        body: Column(
          children: [
            buildAppbar(context),
            buildListChat(context),
            buildBottomBar()
          ],
        ));
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
              gradient:  LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Get.isDarkMode ? const Color(0xFF113751) : Colors.white,
                    Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
                  ]
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 44.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 250, height: 50, child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(onPressed: (){
                          Get.back();
                          }, icon: Image.asset("assets/images/arrow_left.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                              child: CachedNetworkImage(imageUrl: _commonController.userClicked.value == null ? _chatController.conv.value.conversationAvatarUrl : _commonController.userClicked.value!.picture ?? "https://ik.imagekit.io/bayc/assets/bayc-footer.png", width: 40, height: 40, fit: BoxFit.cover,)),
                        ),
                        Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text(_commonController.userClicked.value == null ? _chatController.conv.value.conversationName : _commonController.userClicked.value!.userName ?? _commonController.userClicked.value!.wallet!,style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: Get.isDarkMode ? Colors.white : Colors.black),),
                          //Text(_commonController.userClicked?.value == null ? _chatController.conv.value.conversationName :"${_commonController.userClicked!.value!.wallet!.substring(0,20)}...",style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: "Gilroy", color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282)),)
                        ],),
                      )
                    ],),),
                    IconButton(onPressed: (){Utils().dialogPopMenu(context);}, icon: Image.asset("assets/images/more.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                  ],),
              ),
            ),
          );
  }

  Container buildBottomBar() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.01)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Get.isDarkMode ? const Color(0xFF111D28) : Colors.white,
              Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 3,
            child: TextField(
              controller: _textMessageController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                  ),
                  onPressed: () {},
                ),
                hintText: con.writeHereRes.tr,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282)),
                filled: true,
                fillColor:
                Get.isDarkMode ? const Color(0xFF2D465E) : const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Flexible(
            child: InkWell(
              onTap: ()async{
                ZIMTextMessage textMessage = ZIMTextMessage(message: _textMessageController.text);
                ZIMMessageSendConfig sendConfig = ZIMMessageSendConfig();
                await ZIM
                    .getInstance()!
                    .sendPeerMessage(textMessage, _commonController.userClicked.value == null ? _chatController.conv.value.conversationID :_commonController.userClicked.value!.id!, sendConfig)
                    .then((value) {
                  setState(() {
                    _chatController.chatPagingController.value.itemList!.insert(0, value.message);
                    _textMessageController.clear();
                  });
                })
                    .catchError((onError) {
                  switch (onError.runtimeType) {
                    case PlatformException:
                      break;
                    default:
                  }
                });
              },
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF1DE99B), Color(0xFF0063FB)])),
                child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/send.png",
                      height: 32,
                      width: 32,
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }


  MediaQuery buildListChat(BuildContext context) {
    return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Expanded(
              child: SafeArea(
                child: PagedListView(
                  shrinkWrap: true,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  pagingController: _chatController.chatPagingController.value,
                  builderDelegate: PagedChildBuilderDelegate<ZIMMessage>(itemBuilder: (context, item, index) => buildChatTile(context, index, item as ZIMTextMessage)),
                ),
              ),
            ),
          );
  }


  Widget buildChatTile(BuildContext context, int index, ZIMTextMessage item){
    return Align(alignment: item.senderUserID != _homeController.userMe.value.id! ? Alignment.centerLeft : Alignment.centerRight,
        child:  item.senderUserID != _homeController.userMe.value.id! ?
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Image.network("https://ik.imagekit.io/bayc/assets/bayc-footer.png", width: 40, height: 40, fit: BoxFit.cover,),
            ),
            const SizedBox(width: 8,),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 80.0,top: 8, bottom: 8),
                child: Container(
                  padding:  const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                  gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF102437), Color(0xFF13171B)]),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(0.0, 0.01), //(x,y)
                        blurRadius: Get.isDarkMode ? 0.25 : 0,
                      ),
                    ]
                ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item.message, textAlign: TextAlign.start,style: const TextStyle(color: Colors.white, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 15),),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("12:23",textAlign: TextAlign.end, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600, fontFamily: "Gilroy"),),
                    )
                  ],),
                ),
              ),
            ),
          ],
        ):
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 16, top: 8, bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
            boxShadow: [BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, Get.isDarkMode ? 0 : 0.01), //(x,y)
                blurRadius: Get.isDarkMode ? 0 : 0.25,
              ),],
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.message, textAlign: TextAlign.start, style: const TextStyle(color: Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 15),),
                Padding(padding: const EdgeInsets.only(top: 4.0, left: 0), child: Text("12:23", textAlign: TextAlign.end, style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600, fontFamily: "Gilroy"),),)
              ],),
          ),
        )
    ) ;

  }
  clearUnReadMessage() {
    ZIM.getInstance()!.clearConversationUnreadMessageCount(
        _commonController.userClicked.value == null ? _chatController.conv.value.conversationID : _commonController.userClicked.value!.id!, ZIMConversationType.peer);
  }

  @override
  void dispose() {
    clearUnReadMessage();
    //_chatController.chatPagingController.value.dispose();
    super.dispose();
  }



}
