// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:ethereum_addresses/ethereum_addresses.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/chat_screen.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:sirkl/common/constants.dart' as con;

import '../../global_getx/home/home_controller.dart';
import '../../global_getx/profile/profile_controller.dart';

class CreateGroupSecondScreen extends StatefulWidget {
  const CreateGroupSecondScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupSecondScreen> createState() => _CreateGroupSecondScreenState();
}

class _CreateGroupSecondScreenState extends State<CreateGroupSecondScreen> {

  final _searchController = FloatingSearchBarController();
  final PagingController<int, UserDTO> pagingController = PagingController(firstPageKey: 0);
  final _chatController = Get.put(ChatsController());
  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());
 HomeController get _homeController => Get.find<HomeController>();
  ProfileController get _profileController => Get.find<ProfileController>();  
  final _utils = Utils();

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
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
      body: Obx(() => Column(
        children: [
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
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _chatController.chipsList.isNotEmpty ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Participants",
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
                    _chatController.searchIsActive.value ? const SizedBox(height: 0, width: 0,) :
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
                                  itemBuilder: (context, item, index) => buildUserTile(context, index, item)
                              ))
                      ),
                    )
                  ],
                )),
          ),
        ],
      )),
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
        onTap: () async {},
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(90.0), child:
        item.picture == null ?
        SizedBox(width: 56, height: 56, child: TinyAvatar(baseString: item.wallet!, dimension: 56, circular: true, colourScheme: TinyAvatarColourScheme.seascape,)) :
        CachedNetworkImage(imageUrl: item.picture!, width: 56, height: 56, fit: BoxFit.cover,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
            errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png"))),
        trailing: Checkbox(
          onChanged: (selected) {
            if (item.id.isNullOrBlank!) {
              _utils.showToast(context, "Only users from SIRKL can be part of a group");
            } else {
              if (selected!) {
                _chatController.chipsList.add(item);
              } else {
                _chatController.chipsList.removeWhere((element) =>
                element.wallet == item.wallet);
              }
              _chatController.chipsList.refresh();
            }
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

  Future<void> sendMessageAsGroup() async{
    _chatController.messageSending.value = true;
    var idChannel = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    var wallets = _chatController.chipsList.map((element) => element.wallet!)
        .toList();
    wallets.add(_homeController.userMe.value.wallet!);
    var members = _chatController.chipsList.map((element) => element.id!)
        .toList();
    members.add(_homeController.id.value);
    var idChannelCreated = await _chatController.createInbox(
        InboxCreationDto(
            isConv: false,
            createdBy: _homeController.id.value,
            isGroupPrivate: _chatController.groupType.value == 0 ? false : true,
            isGroupVisible: _chatController.groupVisibility.value == 0 ? true : false,
            wallets: wallets,
            nameOfGroup: _chatController.groupTextController.value.text,
            picOfGroup: _profileController.urlPictureGroup.value,
            idChannel: idChannel,
            members: members));
    _searchController.clear();
    _chatController.chipsList.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    _chatController.messageSending.value = false;
    _profileController.urlPictureGroup.value = "";
    _chatController.groupTextController.value.text = "";
    _chatController.fromGroupCreation.value = true;
    _commonController.refreshInboxes.value = true;
    Navigator.popUntil(context, (route) => route.isFirst);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pushNewScreen(context, screen: DetailedChatScreen(create: false, channelId: idChannelCreated,)).then((value) => _navigationController.hideNavBar.value = false);
    });
//    pushNewScreen(context, screen: const ChatScreen());
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () { Navigator.pop(context); }, child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontFamily: "Gilroy"),),),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Add Participants',
                  style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              TextButton(onPressed: () async{
                if(_chatController.chipsList.isEmpty || _chatController.chipsList.length < 2){
                  _utils.showToast(context, "Please select at least 2 participants");
                } else {
                  await sendMessageAsGroup();
                }
              }, child: Text("Done", style: TextStyle(color: _chatController.chipsList.isNotEmpty && _chatController.chipsList.length >= 2 ? Color(0xff00CB7D) : Colors.grey, fontFamily: "Gilroy"),),),
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
      hint: 'Search by wallet address or ENS',
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

  @override
  void dispose() {
    _chatController.chipsList.clear();

    super.dispose();
  }
}
