// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/model/notification_added_admin_dto.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../common/view/dialog/custom_dial.dart';

class AddUserToGroupScreen extends StatefulWidget {
  const AddUserToGroupScreen({Key? key}) : super(key: key);

  @override
  State<AddUserToGroupScreen> createState() => _AddUserToGroupScreenState();
}

class _AddUserToGroupScreenState extends State<AddUserToGroupScreen> {

  final _callController = Get.put(CallsController());
  final _chatController = Get.put(ChatsController());
  final _commonController = Get.put(CommonController());
  final PagingController<int, UserDTO> pagingController = PagingController(firstPageKey: 0);
  final utils = Utils();
  final _searchController = FloatingSearchBarController();
  static var pageKey = 0;

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
       if(_chatController.addUserQuery.value.isEmpty){
        pagingController.refresh();
        pagingController.appendLastPage(_commonController.users);
      }
    });
    super.initState();
  }

  Future<void> fetchPageUsers() async {
    try {
      List<UserDTO> newItems;
      if(pageKey == 0) newItems = [];
        newItems = await _callController.retrieveUsers(_chatController.addUserQuery.value, pageKey);
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
        extendBody: true,
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Column(children: [
          DeferredPointerHandler(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.topCenter,
              fit: StackFit.loose,
              children: [
                buildAppBar(),
                Positioned(
                    top: Platform.isAndroid ? 80 : 60,
                    child: DeferPointer(
                      child: SizedBox(
                          height: 110,
                          width: MediaQuery.of(context).size.width,
                          child: buildFloatingSearchBar()),
                    )),
              ],
            ),
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 45),
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _chatController.chipsListAddUsers.isEmpty  ? Container() : Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            height: 50,
                            child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: _chatController.chipsListAddUsers.length,
                            itemBuilder: buildToSendChip),
                            ),
                        const SizedBox(height: 24,)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        con.contactsRes.tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            fontFamily: "Gilroy",
                            color:
                            MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),
                      ),
                    ),
                    MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: Expanded(
                          child:
                              PagedListView.separated(
                                separatorBuilder:  (context, index) {
                                  return const Divider(
                                    color: Color(0xFF828282),
                                    thickness: 0.2,
                                    endIndent: 20,
                                    indent: 86,
                                  );
                                },
                                  pagingController: pagingController,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  builderDelegate: PagedChildBuilderDelegate<UserDTO>(
                                      itemBuilder: (context, item, index) => buildNewMessageTile(context, index, item)
                                  ))
                      ),
                    )
                  ],
                ))),
          ),
        ]));
  }

  Container buildAppBar() {
    return Container(
      height: 140,
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
        padding: const EdgeInsets.only(top: 0.0),
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
                child: Text(
                  "Add User",
                  style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              TextButton(
                  onPressed: () async{
                    for (var element in _chatController.chipsListAddUsers) {
                      await _chatController.channel.value?.addMembers([element.id!]);
                      await _commonController.notifyAddedInGroup(NotificationAddedAdminDto(idUser: element.id!, idChannel: _chatController.channel.value!.id!, channelName: _chatController.channel.value!.extraData["nameOfGroup"] as String));
                      _chatController.channel.refresh();
                    }
                    Navigator.pop(context);
                  }, child: const Text("DONE", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: "Gilroy", color: Color(0xFF00CB7D)),),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      automaticallyImplyBackButton: false,
      clearQueryOnClose: false,
      controller: _searchController,
      closeOnBackdropTap: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      hint: 'Search for a user',
      backdropColor: Colors.transparent,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 0),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      queryStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      hintStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xff9BA0A5)
              : const Color(0xFF828282),
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      elevation: 5,
      showCursor: true,
      width: 350,
      accentColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF2D465E).withOpacity(1)
          : Colors.white,
      debounceDelay: const Duration(milliseconds: 200),
      onQueryChanged: (query) async{
        if(query.isNotEmpty) {
          pagingController.itemList = [];
          _chatController.addUserQuery.value = query;
          fetchPageUsers();
        } else {
          pagingController.refresh();
          pagingController.appendLastPage(_commonController.users);
        }
      },
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction.icon(
          icon: Image.asset(
            "assets/images/search.png",
            width: 24,
            height: 24,
          ),
          showIfClosed: true,
          showIfOpened: true,
          onTap: () {
            _searchController.open();
          },
        ),
      ],
      actions: const [],
      builder: (context, transition) {
        return const SizedBox(
          height: 0,
        );
      },
    );
  }

  Widget buildToSendChip(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InputChip(
          deleteIconColor: Colors.white,
          deleteIcon: Image.asset(
            'assets/images/close.png',
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(12),
          onDeleted: () {
            _chatController.chipsListAddUsers.removeAt(index);
            _chatController.chipsListAddUsers.refresh();
          },
          backgroundColor: const Color(0xFF00CB7D),
          label: Text(
            _chatController.chipsListAddUsers[index].userName.isNullOrBlank! ? "${_chatController.chipsListAddUsers[index].wallet!.substring(0, 10)}..." : _chatController.chipsListAddUsers[index].userName!,
            style: const TextStyle(
                fontFamily: "Gilroy",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          )),
    );
  }

  Widget buildNewMessageTile(BuildContext context, int index, UserDTO item) {
    return ListTile(
        leading: InkWell(
            onTap: (){
                _commonController.userClicked.value = item;
                pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: false));
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(90.0), child:
            item.picture == null ?
            SizedBox(width: 56, height: 56, child: TinyAvatar(baseString: item.wallet!, dimension: 56, circular: true, colourScheme: TinyAvatarColourScheme.seascape,)) :
            CachedNetworkImage(imageUrl: item.picture!, width: 56, height: 56, fit: BoxFit.cover,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")))),
        trailing: InkWell(
          onTap: () async {
            var isPresent = await _chatController.channel.value?.queryMembers(filter: Filter.equal("id", item.id!));
            if(isPresent!.members.isEmpty) {
              if(!_chatController.chipsListAddUsers.map((element) => element.id).contains(item.id)) {
                _chatController.chipsListAddUsers.add(item);
              }
            } else {
              utils.showToast(context, "This user is already present in this group");
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              "assets/images/add_user.png",
              color: const Color(0xFF00CB7D),
              width: 20,
              height: 20,
            ),
          ),
        ),
        title: Transform.translate(
          offset: const Offset(-8, 0),
          child: Text(item.nickname != null ? item.nickname! + (item.userName.isNullOrBlank! ? "" : " (${item.userName!})") : item.userName.isNullOrBlank! ? item.wallet! : item.userName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w600,
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)),
        ),
        subtitle: !item.userName.isNullOrBlank! || !item.nickname.isNullOrBlank! ? Transform.translate(
          offset: const Offset(-8, 0),
          child: Text("${item.wallet!.substring(0,6)}...${item.wallet!.substring(item.wallet!.length - 4)}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w500,
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color(0xFF9BA0A5)
                      : const Color(0xFF828282))),
        ) : null
    );
  }

  @override
  void dispose() {
    _chatController.chipsListAddUsers.clear();
    pagingController.dispose();
    _chatController.addUserQuery.value = "";
    super.dispose();
  }

}
