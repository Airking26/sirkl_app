// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:ethereum_addresses/ethereum_addresses.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/chats/ui/create_group_first_screen.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

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
  final _profileController = Get.put(ProfileController());
  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());
  YYDialog dialogMenu = YYDialog();
  final PagingController<int, UserDTO> pagingController = PagingController(firstPageKey: 0);
  final utils = Utils();
  final StreamMessageInputController _messageInputController = StreamMessageInputController();
  final _searchController = FloatingSearchBarController();
  final _groupNameController = TextEditingController();

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
       if(_commonController.query.value.isEmpty){
        pagingController.refresh();
        pagingController.appendLastPage(_commonController.users);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() =>Column(children: [
          DeferredPointerHandler(
            child: Stack(
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
                      child: DeferPointer(
                        child: buildFloatingSearchBar(),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _chatController.searchIsActive.value ?const SizedBox(height: 0, width: 0,) :  Column(
                      children: [
                        ListTile(leading: IconButton(icon : Icon(Icons.groups, size: 28, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,), onPressed: (){}, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,),tileColor: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white, title: Text("New group", style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),), contentPadding: const EdgeInsets.symmetric(horizontal: 16,),onTap: (){
                          _navigationController.hideNavBar.value = true;
                          pushNewScreen(context, screen: const CreateGroupFirstScreen()).then((value) => _navigationController.hideNavBar.value = true);
                          _chatController.sendingMessageMode.value = 1;
                          _chatController.chipsList.clear();
                        }),
                        const SizedBox(height: 4,),
                        ListTile(leading: IconButton(icon : Icon(Icons.volume_up_rounded, size: 28, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,), onPressed: (){}, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,),tileColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white , title: Text("New broadcast list", style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),), contentPadding: const EdgeInsets.symmetric(horizontal: 16), onTap: (){
                          _chatController.sendingMessageMode.value = 2;
                          _chatController.chipsList.clear();
                        },),
                        const SizedBox(height: 4,),
                        ListTile(leading: IconButton(icon : Image.asset("assets/images/add_user.png", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, width: 22, height: 22,), onPressed: (){}, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,),tileColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white, title: Text("Add a user to my SIRKL", style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16, color : MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),), contentPadding: const EdgeInsets.symmetric(horizontal: 16), onTap: (){
                          _searchController.open();
                          _chatController.searchIsActive.value = true;
                          pagingController.itemList = [];
                          _chatController.sendingMessageMode.value = 3;
                          _chatController.chipsList.clear();
                        },),
                        const SizedBox(height: 16,),
                      ],
                    ),
                    _chatController.chipsList.isNotEmpty ?
                    Column(
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
                                MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),
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
                              itemBuilder: buildChip),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                      ],
                    ) : Container(),
                    _chatController.searchIsActive.value ? const SizedBox(height: 0, width: 0,) : Padding(
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
                                      itemBuilder: (context, item, index) => buildUserTile(context, index, item)
                                  ))
                      ),
                    )
                  ],
                )),
          ),
          _chatController.sendingMessageMode.value == 2 ?buildBottomBar() : const SizedBox(height: 0, width: 0,),
        ])));
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
        padding: const EdgeInsets.only(top: 44.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){Navigator.pop(context);},
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: ImageIcon(const AssetImage(
                    "assets/images/arrow_left.png",
                  ),color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  con.newMessageRes.tr,
                  style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              IconButton(
                  onPressed: () {
                    _navigationController.hideNavBar.value = true;
                    pushNewScreen(context, screen: const NewMessageScreen()).then((value) => _navigationController.hideNavBar.value = false);
                  },
                  icon: Image.asset(
                    "assets/images/plus.png",
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.transparent
                        : Colors.transparent,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  FloatingSearchBar buildFloatingSearchBar() {
    return FloatingSearchBar(
      automaticallyImplyBackButton: false,
      clearQueryOnClose: true,
      controller: _searchController,
      closeOnBackdropTap: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      hint: 'Paste a wallet address or an ENS',
      backdropColor: Colors.transparent,
      scrollPadding: const EdgeInsets.only(top: 0, bottom: 0),
      transitionDuration: const Duration(milliseconds: 0),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      queryStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
          fontSize: 16,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      hintStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xff9BA0A5)
              : const Color(0xFF828282),
          fontSize: 16,
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
        if(query.isNotEmpty && query.contains('.eth')){
          String? ethFromEns = await _chatController.getEthFromEns(query, _homeController.userMe.value.wallet!);
          if(_profileController.isUserExists.value == null && ethFromEns != "" && ethFromEns != "0") {
            pagingController.itemList = [UserDTO(id: '', userName: query, picture: "", isAdmin: false, createdAt: DateTime.now(), description: '', fcmToken: "", wallet: ethFromEns, following: 0, isInFollowing: false)];
          } else if(_profileController.isUserExists.value != null){
            pagingController.itemList = [_profileController.isUserExists.value!];
          }
          else {
            pagingController.itemList = [];
          }
        }
        else if(query.isNotEmpty && isValidEthereumAddress(query.toLowerCase()) && query.toLowerCase() != _homeController.userMe.value.wallet!.toLowerCase()){
          _profileController.isUserExists.value = await _profileController.getUserByWallet(query.toLowerCase());
          if(_profileController.isUserExists.value == null) {
            pagingController.itemList = [UserDTO(id: '', userName: "", picture: "", isAdmin: false, createdAt: DateTime.now(), description: '', fcmToken: "", wallet: query.toLowerCase(), following: 0, isInFollowing: false)];
          } else {
            pagingController.itemList = [_profileController.isUserExists.value!];
          }
        }
        else {
          if(query.isNotEmpty) {
            _chatController.searchIsActive.value = true;
            pagingController.itemList = [];
          } else {
            _chatController.searchIsActive.value = false;
            pagingController.refresh();
          }
        }
      },
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction.icon(
          icon:  Image.asset(
            "assets/images/search.png",
            width: 24,
            height: 24,
            color: Colors.grey,
          ),
          showIfClosed: true,
          showIfOpened: true,
          onTap: () {
            if(_chatController.searchIsActive.value) {
              _chatController.searchIsActive.value = false;
              _searchController.close();
              _chatController.sendingMessageMode.value = 0;
              pagingController.refresh();
            } else {
              _chatController.searchIsActive.value = true;
              _searchController.open();
            }
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

  Widget buildChip(BuildContext context, int index) {
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

  Widget buildUserTile(BuildContext context, int index, UserDTO item) {
    return Obx(() =>ListTile(
      onTap: () async {
        if(_chatController.sendingMessageMode.value == 0 || _chatController.sendingMessageMode.value == 3){
          if(item.id.isNullOrBlank!) {
            var idChannel = DateTime
                .now()
                .millisecondsSinceEpoch
                .toString();
           var idChannelCreated = await _chatController.createInbox(InboxCreationDto(
                isConv: true,
                createdBy: _homeController.id.value,
                wallets: [
                  _homeController.userMe.value.wallet!,
                  item.wallet!
                ],
                idChannel: idChannel));
           _navigationController.hideNavBar.value = true;
            pushNewScreen(context, screen: DetailedChatScreen(
                create: false, channelId: idChannelCreated)).then((value) => _navigationController.hideNavBar.value = true);
          } else {
            _navigationController.hideNavBar.value = true;
            _commonController.userClicked.value = item;
            pushNewScreen(
                context, screen: const DetailedChatScreen(create: true)).then((value) => _navigationController.hideNavBar.value = true);
          }
        }
      },
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(90.0), child:
        item.picture == null ?
        SizedBox(width: 56, height: 56, child: TinyAvatar(baseString: item.wallet!, dimension: 56, circular: true, colourScheme: TinyAvatarColourScheme.seascape,)) :
        CachedNetworkImage(imageUrl: item.picture!, width: 56, height: 56, fit: BoxFit.cover,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
            errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png"))),
        trailing: _chatController.sendingMessageMode.value == 2 ? Checkbox(
          onChanged: (selected) {
            if (_chatController.chipsList.value.length == 3 && _chatController.sendingMessageMode.value == 2) {
              utils.showToast(context, con.maxUserSelectedRes.tr);
            }
            else if (selected!) {
                _chatController.chipsList.add(item);
              } else {
                _chatController.chipsList.removeWhere((element) =>
                element.wallet == item.wallet);
              }
              _chatController.chipsList.refresh();
          },
          value: _chatController.chipsList.map((element) => element.wallet).contains(item.wallet),
          checkColor: const Color(0xFF00CB7D),
          fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
          side: MaterialStateBorderSide.resolveWith(
            (states) => const BorderSide(width: 1.0, color: Color(0xFF00CB7D)),
          ),
        ) :
        /*_chatController.sendingMessageMode.value == 3 ? Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(icon : item.id.isNullOrBlank! ? Image.asset("assets/images/chat_tab.png", color:  const Color(0xFF00CB7D),) :
          const Icon(Icons.person_add_alt_1_rounded, size: 28,), onPressed: () async {
            if(item.id.isNullOrBlank!){
              var idChannel = DateTime
                  .now()
                  .millisecondsSinceEpoch
                  .toString();
              var idChannelCreated = await _chatController.createInbox(InboxCreationDto(
                  isConv: true,
                  createdBy: _homeController.id.value,
                  wallets: [
                    _homeController.userMe.value.wallet!,
                    item.wallet!
                  ],
                  idChannel: idChannel));
              _navigationController.hideNavBar.value = true;
              pushNewScreen(context, screen: DetailedChatScreen(
                  create: false, channelId: idChannelCreated)).then((value) => _navigationController.hideNavBar.value = true);
            } else {
              _commonController.userClicked.value = item;
              if (await _commonController.addUserToSirkl(
                  _commonController.userClicked.value!.id!, StreamChat
                  .of(context)
                  .client, _homeController.id.value)) {
                utils.showToast(context,
                    con.userAddedToSirklRes.trParams({"user": _commonController
                        .userClicked.value!.userName ?? _commonController
                        .userClicked.value!.wallet!}));
              } else {
                utils.showToast(context, "This user is already in your SIRKL");
              }
            }
          }, color: const Color(0xFF00CB7D),),
        ) :*/
        const SizedBox(height: 0, width: 0,),
        title: Transform.translate(
          offset: const Offset(-8, 0),
          child: Text(item.nickname != null ? item.nickname! + (item.userName.isNullOrBlank! ? "" : " (${item.userName!})") : item.userName.isNullOrBlank! ? "${item.wallet!.substring(0, 6)}...${item.wallet!.substring(item.wallet!.length - 4)}" : item.userName!,
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
    ));
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
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF111D28) : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 3,
            child: TextField(
              controller: _messageInputController.textFieldController,
              decoration: InputDecoration(
                hintText: con.writeHereRes.tr,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282)),
                filled: true,
                fillColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF2D465E) : const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Flexible(
            child: InkWell(
              onTap: () async {
                if(_chatController.chipsList.length <2){
                  utils.showToast(context, "Please, choose at least 2 participants");
                }
                 else if(_chatController.sendingMessageMode.value == 2 && _messageInputController.text.isNotEmpty && !_messageInputController.text.isBlank!){
                  await sendMessageAsBroadcastList();
                }
              },
              child:
                  _chatController.messageSending.value ?
                      const SizedBox(width: 55, height: 55, child: Center(child: CircularProgressIndicator(color: Color(0xff00CB7D),),)) :
              Container(
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


  Future<void> sendMessageAsBroadcastList() async {
    _chatController.messageSending.value = true;
    for (UserDTO element in _chatController.chipsList) {
      String? idChannelCreated;
      var idChannel = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      if (element.id.isNullOrBlank!) {
        idChannelCreated = await _chatController.createInbox(InboxCreationDto(
          isConv: true,
            createdBy: _homeController.id.value,
            wallets: [
              _homeController.userMe.value.wallet!,
              element.wallet!
            ],
            idChannel: idChannel,
            message: _messageInputController.text));
      } else {
        await _chatController.createInbox(InboxCreationDto(
          isConv: true,
            createdBy: _homeController.id.value,
            wallets: [
              _homeController.userMe.value.wallet!,
              element.wallet!
            ],
            idChannel: idChannel,
            message: _messageInputController.text,
            members: [_homeController.id.value, element.id!]));
      }
      if (_chatController.chipsList.value.indexOf(element) ==
          _chatController.chipsList.length - 1) {
        _messageInputController.clear();
        _searchController.clear();
        FocusManager.instance.primaryFocus?.unfocus();
        _chatController.messageSending.value = false;
        if (_chatController.chipsList.value.length == 1) {
          Navigator.pop(context);
          if (element.id.isNullOrBlank!) {
            _navigationController.hideNavBar.value = true;
            pushNewScreen(context, screen: DetailedChatScreen(
                create: false, channelId: idChannelCreated)).then((value) => _navigationController.hideNavBar.value = false);
          } else {
            _commonController.userClicked.value =
            _chatController.chipsList[0];
            _navigationController.hideNavBar.value = true;
            pushNewScreen(context, screen: const DetailedChatScreen(create: true)).then((value) => _navigationController.hideNavBar.value = false);
          }
        }
        else {
          Navigator.pop(context);
        }
      }
    }
    _chatController.chipsList.clear();
  }

  @override
  void dispose() {
    _chatController.searchIsActive.value = false;
    _chatController.sendingMessageMode.value = 0;
    _chatController.chipsList.clear();
    pagingController.dispose();
    _commonController.query.value = "";
    super.dispose();
  }

}
