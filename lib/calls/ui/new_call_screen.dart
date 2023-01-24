import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../common/view/dialog/custom_dial.dart';

class NewCallScreen extends StatefulWidget {
  const NewCallScreen({Key? key}) : super(key: key);

  @override
  State<NewCallScreen> createState() => _NewCallScreenState();
}

class _NewCallScreenState extends State<NewCallScreen> {

  final _callController = Get.put(CallsController());
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final PagingController<int, UserDTO> pagingController = PagingController(firstPageKey: 0);
  final utils = Utils();
  final _searchController = FloatingSearchBarController();
  static var pageKey = 0;

  @override
  void initState() {
    _callController.focusNode.value;
    pagingController.addPageRequestListener((pageKey) {
       if(_callController.callQuery.value.isEmpty){
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
        newItems = await _callController.retrieveUsers(_callController.callQuery.value, pageKey);
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
                )),
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
        padding: const EdgeInsets.only(top: 44.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "assets/images/arrow_left.png",
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  con.newCallRes.tr,
                  style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              IconButton(
                  onPressed: () {
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

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      automaticallyImplyBackButton: false,
      clearQueryOnClose: false,
      controller: _searchController,
      closeOnBackdropTap: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      hint: 'Paste a wallet address or a username',
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
          _callController.callQuery.value = query;
          fetchPageUsers();
        } else {
          pagingController.refresh();
          pagingController.appendLastPage(_commonController.users);
        }
        /*if(query.isNotEmpty && query.contains('.eth')){
          String? ethFromEns = await _chatController.getEthFromEns(query);
          if(_profileController.isUserExists.value == null && ethFromEns != "" && ethFromEns != "0") {
            pagingController.itemList = [UserDTO(id: '', userName: query, picture: "", isAdmin: false, createdAt: DateTime.now(), description: '', fcmToken: "", wallet: ethFromEns, following: 0, isInFollowing: false)];
          } else if(_profileController.isUserExists.value != null){
            pagingController.itemList = [_profileController.isUserExists.value!];
          }
          else {
            pagingController.itemList = [];
          }
        }
        else if(query.isNotEmpty && isValidEthereumAddress(query.toLowerCase())){
          _profileController.isUserExists.value = await _profileController.getUserByWallet(query.toLowerCase());
          if(_profileController.isUserExists.value == null) {
            pagingController.itemList = [UserDTO(id: '', userName: "", picture: "", isAdmin: false, createdAt: DateTime.now(), description: '', fcmToken: "", wallet: query.toLowerCase(), following: 0, isInFollowing: false)];
          } else {
            pagingController.itemList = [_profileController.isUserExists.value!];
          }
        }
        else {
          if(query.isNotEmpty) {
            pagingController.itemList = [];
          } else {
            pagingController.refresh();
          }
        }*/
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
            CachedNetworkImage(imageUrl: item.picture!, width: 56, height: 56, fit: BoxFit.cover,placeholder: (context, url) => Center(child: const CircularProgressIndicator(color: Color(0xff00CB7D))),
                errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")))),
        trailing: InkWell(
          onTap: () async {
            _callController.userCalled.value = item;
            await _callController.inviteCall(item, DateTime.now().toString(), _homeController.id.value);
          },
          child: Image.asset(
            "assets/images/call_tab.png",
            color: const Color(0xFF00CB7D),
            width: 20,
            height: 20,
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
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)),
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
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color(0xFF9BA0A5)
                      : const Color(0xFF828282))),
        ) : null
    );
  }

  @override
  void dispose() {
    _callController.focusNode.value.dispose();
    pagingController.dispose();
    _callController.callQuery.value = "";
    super.dispose();
  }

}
