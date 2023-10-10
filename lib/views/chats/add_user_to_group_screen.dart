// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/global_getx/web3/web3_controller.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';
import 'package:sirkl/common/model/notification_added_admin_dto.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/global_getx/calls/calls_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/global_getx/common/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/global_getx/home/home_controller.dart';

import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:web3dart/web3dart.dart';

import '../../config/s_colors.dart';
import '../../views/profile/profile_else_screen.dart';

class AddUserToGroupScreen extends StatefulWidget {
  const AddUserToGroupScreen({Key? key}) : super(key: key);

  @override
  State<AddUserToGroupScreen> createState() => _AddUserToGroupScreenState();
}

class _AddUserToGroupScreenState extends State<AddUserToGroupScreen> {

  CallsController get _callController => Get.find<CallsController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  CommonController get _commonController => Get.find<CommonController>();
  Web3Controller get _web3Controller => Get.find<Web3Controller>();
  HomeController get _homeController => Get.find<HomeController>();
  final _priceController = TextEditingController();
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
              Text(
                _chatController.channel.value!.extraData["isGroupPaying"] != null ? "Send Invite" : "Add User",
                style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Gilroy",
                    fontSize: 20),
              ),
              _chatController.channel.value!.extraData["isGroupPaying"] != null ? const SizedBox(width: 42, height: 42,) : TextButton(
                  onPressed: () async{
                    for (var element in _chatController.chipsListAddUsers) {
                      await _chatController.channel.value?.addMembers([element.id!]);
                      await _commonController.notifyAddedInGroup(NotificationAddedAdminDto(idUser: element.id!, idChannel: _chatController.channel.value!.id!, channelName: _chatController.channel.value!.extraData["nameOfGroup"] as String));
                      _chatController.channel.refresh();
                    }
                    Navigator.pop(context);
                  }, child:  Text("DONE", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: "Gilroy", color: SColors.activeColor),),
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
          backgroundColor: SColors.activeColor,
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
            CachedNetworkImage(imageUrl: item.picture!, width: 56, height: 56, fit: BoxFit.cover,placeholder: (context, url) =>  Center(child: CircularProgressIndicator(color: SColors.activeColor)),
                errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")))),
        trailing: InkWell(
          onTap: () async {
            if(_chatController.channel.value!.extraData["isGroupPaying"] != null){
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) =>
                      CupertinoAlertDialog(
                        title: Text(
                          "Invite",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              color: MediaQuery.of(context)
                                  .platformBrightness ==
                                  Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        content: Text(
                            "By clicking 'Custom Fee' you'll be able to set a special fee for this user to pay to join the group, else the default fee will apply.",
                            //"Once approved by the admin, you can join the group by paying a ${channel.extraData["price"] is double ? channel.extraData["price"] as double : (channel.extraData["price"] as int).toDouble()}ETH subscription fee.",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Gilroy",
                                color: MediaQuery.of(context)
                                    .platformBrightness ==
                                    Brightness.dark
                                    ? Colors.white
                                    .withOpacity(0.5)
                                    : Colors.black
                                    .withOpacity(0.5))),
                        actions: [
                          CupertinoDialogAction(
                            child: Text("Custom Fee",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Gilroy",
                                    color: MediaQuery.of(
                                        context)
                                        .platformBrightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.black)),
                            onPressed: () {
                              Get.back();
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (_) =>
                                      CupertinoAlertDialog(
                                        title: Text(
                                          "Admission Price",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                              fontFamily:
                                              "Gilroy",
                                              color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                                  Brightness
                                                      .dark
                                                  ? Colors
                                                  .white
                                                  : Colors
                                                  .black),
                                        ),
                                        content: Material(
                                          color: Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Transform.translate(offset: const Offset(0, 3.75),
                                                    child:  SizedBox(width: 50,
                                                      child: TextField(
                                                        controller: _priceController,
                                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                        textAlign: TextAlign.center,cursorColor: SColors.activeColor, decoration: const InputDecoration(
                                                        hintText: "0.0", hintStyle: TextStyle(fontWeight: FontWeight.w500, fontFamily: "Gilroy", fontSize: 18),contentPadding: EdgeInsets.only(bottom: 4), isDense: true, enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                                                      ), focusedBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                                                      ),  ),),)),
                                                const SizedBox(width: 4,),
                                                DropdownButton<dynamic>(
                                                    items: [DropdownMenuItem(
                                                        child: Row(
                                                          children: [
                                                            Image.network(
                                                              "https://raw.githubusercontent.com/dappradar/tokens/main/ethereum/0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee/logo.png",
                                                              width: 22,
                                                              height: 22,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            const Text(
                                                              "ETH",
                                                              style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500),
                                                            )
                                                          ],
                                                        ))],
                                                    onChanged: (any){})
                                              ],),
                                          ),
                                        ),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: Text("Invite",
                                                style: TextStyle(
                                                    fontSize:
                                                    16,
                                                    fontWeight:
                                                    FontWeight
                                                        .w600,
                                                    fontFamily:
                                                    "Gilroy",
                                                    color: MediaQuery.of(context).platformBrightness ==
                                                        Brightness
                                                            .dark
                                                        ? Colors
                                                        .white
                                                        : Colors
                                                        .black)),
                                            onPressed:
                                                () async {
                                                  if(_priceController.text.isNotEmpty && isNumeric(_priceController.text)) {
                                                    Get.back();
                                                    AlertDialog alert = _web3Controller
                                                        .blockchainInfo(
                                                        "Please, wait while the transaction is processed. This may take some time.");
                                                    var connector = await _web3Controller
                                                        .connect();
                                                    connector.onSessionConnect
                                                        .subscribe((
                                                        args) async {
                                                      await _web3Controller
                                                          .sendInviteMethod(
                                                          connector,
                                                          args,
                                                          context,
                                                          _chatController
                                                              .channel.value!,
                                                          _homeController.userMe
                                                              .value.wallet!,
                                                          alert,
                                                          item,
                                                          double.parse(_priceController.text.replaceAll(RegExp('[^A-Za-z0-9]'), '.')));
                                                    });
                                                  }
                                            },
                                          )
                                        ],
                                      ));
                              },
                          ),
                          CupertinoDialogAction(
                            child: Text("Default Fee",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Gilroy",
                                    color: MediaQuery.of(
                                        context)
                                        .platformBrightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.black)),
                            onPressed: () async {
                              Get.back();
                              AlertDialog alert = _web3Controller.blockchainInfo("Please, wait while the transaction is processed. This may take some time.");
                              var connector = await _web3Controller.connect();
                              connector.onSessionConnect.subscribe((args) async {
                                await _web3Controller.sendInviteMethod(connector, args, context, _chatController.channel.value!, _homeController.userMe.value.wallet!, alert, item, _chatController.channel.value!.extraData["price"] as double);
                              });
                            },
                          )
                        ],
                      ));
            } else {
              var isPresent = await _chatController.channel.value?.queryMembers(
                  filter: Filter.equal("id", item.id!));
              if (isPresent!.members.isEmpty) {
                if (!_chatController.chipsListAddUsers.map((element) =>
                element.id).contains(item.id)) {
                  _chatController.chipsListAddUsers.add(item);
                }
              } else {
                utils.showToast(
                    context, "This user is already present in this group");
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              "assets/images/add_user.png",
              color: SColors.activeColor,
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
