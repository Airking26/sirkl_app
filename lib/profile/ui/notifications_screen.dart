// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/model/request_to_join_dto.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/notification_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import '../../common/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controller/profile_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  final _profileController = Get.put(ProfileController());
  final _homeController = Get.put(HomeController());
  final _chatController = Get.put(ChatsController());
  final _commonController = Get.put(CommonController());
  final PagingController<int, NotificationDto> pagingController = PagingController(firstPageKey: 0);
  static var pageKey = 0;

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      fetchPageNotifications();
    });
    super.initState();
  }

  Future<void> fetchPageNotifications() async {
    try {
      List<NotificationDto> newItems = await _profileController.retrieveNotifications(_homeController.id.value, pageKey);
      final isLastPage = newItems.length < 12;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey++;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
        body: Column(
          children: [
            Container(
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
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
                gradient:  LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
                      MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
                    ]
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                        child: Text(con.notificationsRes.tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                      ),
                      IconButton(onPressed: (){}, icon: Image.asset("assets/images/more.png", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.transparent : Colors.transparent,)),
                    ],),
                ),
              ),
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Expanded(child:
              SafeArea(
                //minimum: const EdgeInsets.only(top: 16),
                child: PagedListView.separated(
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<NotificationDto>(itemBuilder: (context, item, index) => buildNotificationTile(context, item, index),),
                    separatorBuilder: (context, index){return Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF9BA0A5) : const Color(0xFF828282), thickness: 0.2, endIndent: 20, indent: 20, height: 0,);},
                ),
              )
              ),
            )
          ],
        ));
  }

  Widget buildNotificationTile(BuildContext context, NotificationDto item, int index){
    return Container(
      color: item.hasBeenRead ? Colors.transparent : MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF9BA0A5).withOpacity(0.1) : const Color(0xFF828282).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
        child: ListTile(
          onTap: () async{
            await _commonController.getUserById(item.idData);
            pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: false, fromNested: true,));
          },
          trailing: item.type == 7 ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            IconButton(onPressed: () async {
              if(await _chatController.acceptDeclineRequest(RequestToJoinDto(receiver: _homeController.id.value, requester: item.requester, channelName: item.channelName, channelId: item.channelId, accept: true, paying: item.paying))) {
                await _profileController.deleteNotification(item.id);
                pagingController.refresh();
              }
            }, icon: const Icon(Icons.add, color: Color(0xff00CB7D),)),
            IconButton(onPressed: () async {
              if(await _chatController.acceptDeclineRequest(RequestToJoinDto(receiver: _homeController.id.value, requester: item.requester, channelName: item.channelName, channelId: item.channelId, accept: false, paying: item.paying))) {
                await _profileController.deleteNotification(item.id);
                pagingController.refresh();
              }
            }, icon: const Icon(Icons.close_rounded, color: Colors.grey,))
          ],) : const SizedBox(),
          leading:
              item.type != 0 && item.type != 1 && item.type != 5 && item.type != 6 && item.type != 7?
                  Container(
                    width: 50, height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff00CB7D),
                      ),
                  child: Align(alignment: Alignment.center, child: Image.asset('assets/images/stories.png', width: 24, height: 24,),),) :
          item.picture.isNullOrBlank! ?
          SizedBox(height: 50, width: 50, child: TinyAvatar(baseString: item.wallet?? "", dimension: 50, circular: true, colourScheme:TinyAvatarColourScheme.seascape )) :
          ClipRRect(
            borderRadius: BorderRadius.circular(90),
            child: CachedNetworkImage(imageUrl: item.picture!, width: 50, height: 50, fit: BoxFit.cover,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png", width: 50, height: 50, fit: BoxFit.cover)),
          ),
          title: Transform.translate(
            offset: Offset(item.picture.isNullOrBlank! ? 0 : -8, 0),
            child: buildTextNotif(item),
          ),
          //subtitle: Text("Lorem Ipsum is simply...", style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Get.isDarkMode ? Color(0xFF9BA0A5) : Color(0xFF828282))),
        ),
      ),
    );
  }

  Widget? buildTextNotif(NotificationDto item){
    var nowMilli = DateTime.now().millisecondsSinceEpoch;
    var updatedAtMilli =  DateTime.parse(item.createdAt.toIso8601String()).millisecondsSinceEpoch;
    var diffMilli = nowMilli - updatedAtMilli;
    var timeSince = DateTime.now().subtract(Duration(milliseconds: diffMilli));
    if(item.type == 0){
      return RichText(
        text: TextSpan(
            style: const TextStyle(),
            children: [
              TextSpan(text: item.username ?? item.wallet , style: const TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Color(0xff00CB7D))),
              TextSpan(text: " added you in his SIRKL - ${timeago.format(timeSince)}", style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black.withOpacity(0.6))),
            ]
        ),
      );
    } else if(item.type == 1){
      return RichText(
        text: TextSpan(
            style: const TextStyle(),
            children: [
              TextSpan(text: "You have added ", style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color:MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black.withOpacity(0.6))),
              TextSpan(text: item.username ?? item.wallet , style: const TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Color(0xff00CB7D))),
              TextSpan(text: " in your SIRKL - ${timeago.format(timeSince)}", style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black.withOpacity(0.6))),
            ]
        ),
      );
    } else if(item.type == 4 || item.type == 5 || item.type == 6 || item.type == 7){
      return Text(item.message!, style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color:MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black.withOpacity(0.6)));
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    pageKey = 0;
    pagingController.dispose();
    super.dispose();
  }
}
