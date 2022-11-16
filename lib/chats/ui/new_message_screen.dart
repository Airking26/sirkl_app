import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:zego_zim/zego_zim.dart';

import '../../common/view/dialog/custom_dial.dart';
import '../controller/chats_controller.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {

  final _chatController = Get.put(ChatsController());
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  YYDialog dialogMenu = YYDialog();
  static var _pageKey = 0;
  final PagingController<int, UserDTO> pagingController = PagingController(firstPageKey: 0);
  final _textMessageController = TextEditingController();
  final utils = Utils();

  @override
  void initState() {
    _chatController.searchToRefresh.value = true;
    pagingController.addPageRequestListener((pageKey) {
      if(_commonController.query.value.isNotEmpty) {
        fetchPage(_commonController.query.value, _pageKey);
      } else {
        pagingController.refresh();
        pagingController.appendLastPage(_commonController.users);
      }
    });
    super.initState();
  }

  Future<void> fetchPage(String query, int pageKey) async {
    try {
      final newItems = await _commonController.searchUsers(query, _pageKey.toString());
      final isLastPage = newItems.length < 12;
      if (isLastPage) {
        if(pageKey == 0 && _chatController.searchToRefresh.value){
          pagingController.itemList = [];
          _chatController.searchToRefresh.value = false;
          pagingController.refresh();
        } else {
          pagingController.appendLastPage(newItems);
        }
      } else {
        final nextPageKey = _pageKey++;
        pagingController.refresh();
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
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() =>Column(children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.topCenter,
            fit: StackFit.loose,
            children: [
              buildAppBar(),
              Positioned(
                  top: Platform.isAndroid ? 80 : 60,
                  child: SizedBox(
                      height: 110,
                      width: MediaQuery.of(context).size.width,
                      child: buildFloatingSearchBar())),
            ],
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _chatController.chipsList.isNotEmpty ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            con.toRes.tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                fontFamily: "Gilroy",
                                color:
                                Get.isDarkMode ? Colors.white : Colors.black),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          height: 50,
                          child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: _chatController.chipsList.length,
                              itemBuilder: buildToSendChip),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                      ],
                    ) : Container(),

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
                                Get.isDarkMode ? Colors.white : Colors.black),
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
                )),
          ),
          buildBottomBar()
        ])));
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
              onTap: () async {
                await _chatController.bulkPeerMessages(_chatController.chipsList.value.map((e) => InboxCreationDto(lastMessage: _textMessageController.text, updatedAt: DateTime.now(), lastSender: _homeController.id.value, unreadMessages: 1, ownedBy: [_homeController.id.value, e.id!])).toList());
                ZIMTextMessage textMessage = ZIMTextMessage(message: _textMessageController.text);
                ZIMMessageSendConfig sendConfig = ZIMMessageSendConfig();
                _chatController.chipsList.map((element) => element.id).forEach((id) async{
                  await ZIM
                      .getInstance()!
                      .sendPeerMessage(textMessage, id!, sendConfig).then((value) {
                        var f = value;
                  })
                      .catchError((onError) {
                    switch (onError.runtimeType) {
                      case PlatformException:
                        break;
                      default:
                    }
                  });
                });
                _textMessageController.clear();
                FocusManager.instance.primaryFocus?.unfocus();
                _chatController.chipsList.clear();
                utils.showToast(context, con.messageSuccessfullySentRes.tr);

              },
              child: Flexible(
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
            ),
          )
        ],
      ),
    );
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
              Get.isDarkMode ? const Color(0xFF113751) : Colors.white,
              Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 44.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Image.asset(
                    "assets/images/arrow_left.png",
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  con.newMessageRes.tr,
                  style: TextStyle(
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Get.to(() => const NewMessageScreen());
                  },
                  icon: Image.asset(
                    "assets/images/plus.png",
                    color: Get.isDarkMode
                        ? Colors.transparent
                        : Colors.transparent,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNewMessageTile(BuildContext context, int index, UserDTO item) {
    return ListTile(
        leading: InkWell(
            onTap: (){
              _commonController.userClicked.value = item;
              Get.to(() => const ProfileElseScreen());
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(90.0), child:
            item.picture == null ?
            SizedBox(width: 60, height: 60, child: TinyAvatar(baseString: item.wallet!, dimension: 56, circular: true, colourScheme: TinyAvatarColourScheme.seascape,)) :
            CachedNetworkImage(imageUrl: item.picture!, width: 56, height: 56, fit: BoxFit.cover,))),
        trailing: Checkbox(
          onChanged: (selected) {
            if(selected!) {
              _chatController.chipsList.add(item);
            } else {
              _chatController.chipsList.removeWhere((element) => element.wallet == item.wallet);
            }
            _chatController.chipsList.refresh();
          },
          value: _chatController.chipsList.map((element) => element.wallet).contains(item.wallet),
          checkColor: const Color(0xFF00CB7D),
          fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
          side: MaterialStateBorderSide.resolveWith(
            (states) => const BorderSide(width: 1.0, color: Color(0xFF00CB7D)),
          ),
        ),
        title: Transform.translate(
          offset: const Offset(-8, 0),
          child: Text(item.userName.isNullOrBlank! ? item.wallet! : item.userName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode ? Colors.white : Colors.black)),
        ),
        subtitle: !item.userName.isNullOrBlank! ? Transform.translate(
          offset: const Offset(-8, 0),
          child: Text(item.wallet!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w500,
                  color: Get.isDarkMode
                      ? const Color(0xFF9BA0A5)
                      : const Color(0xFF828282))),
        ) : null
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
            _chatController.chipsList.removeAt(index);
            _chatController.chipsList.refresh();
          },
          backgroundColor: const Color(0xFF00CB7D),
          label: Text(
            _chatController.chipsList[index].userName.isNullOrBlank! ? "${_chatController.chipsList[index].wallet!.substring(0, 10)}..." : _chatController.chipsList[index].userName!,
            style: const TextStyle(
                fontFamily: "Gilroy",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          )),
    );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      automaticallyImplyBackButton: false,
      clearQueryOnClose: false,
      closeOnBackdropTap: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      hint: 'Search here...',
      backdropColor: Colors.transparent,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 0),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      queryStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.black,
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      hintStyle: TextStyle(
          color: Get.isDarkMode
              ? const Color(0xff9BA0A5)
              : const Color(0xFF828282),
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      elevation: 5,
      showCursor: true,
      width: 350,
      accentColor: Get.isDarkMode ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor: Get.isDarkMode
          ? const Color(0xFF2D465E).withOpacity(1)
          : Colors.white,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        _chatController.searchToRefresh.value = true;
        _commonController.query.value = query;
        _pageKey = 0;
        if(query.isNotEmpty) fetchPage(_commonController.query.value, _pageKey);
        else pagingController.refresh();
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
          onTap: () {},
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

  @override
  void dispose() {
    _chatController.searchToRefresh.value = true;
    _chatController.chipsList.clear();
    pagingController.dispose();
    _commonController.query.value = "";
    super.dispose();
  }

}
