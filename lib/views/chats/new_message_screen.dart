// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:ethereum_addresses/ethereum_addresses.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/controllers/call_controller.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/inbox_controller.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/models/inbox_creation_dto.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/views/global/material_floating_search_bar/floating_search_bar.dart';
import 'package:sirkl/views/global/material_floating_search_bar/floating_search_bar_actions.dart';
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/profile_controller.dart';
import 'add_contact_screen.dart';
import 'create_group_first_screen.dart';
import 'detailed_chat_screen.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  InboxController get _chatController => Get.find<InboxController>();
  HomeController get _homeController => Get.find<HomeController>();
  ProfileController get _profileController => Get.find<ProfileController>();
  CommonController get _commonController => Get.find<CommonController>();
  CallController get _callController => Get.find<CallController>();
  NavigationController get _navigationController =>
      Get.find<NavigationController>();
  final PagingController<int, UserDTO> pagingController =
      PagingController(firstPageKey: 0);
  final StreamMessageInputController _messageInputController =
      StreamMessageInputController();
  final _searchController = FloatingSearchBarController();
  static var pageKey = 0;

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      if (_commonController.query.value.isEmpty) {
        pagingController.refresh();
        pagingController.appendLastPage(_commonController.users);
      } else
        fetchPageUsers();
    });
    super.initState();
  }

  Future<void> fetchPageUsers() async {
    _commonController.isSearchLoading.value = true;
    try {
      List<UserDTO> newItems;
      if (pageKey == 0) newItems = [];
      newItems = await _callController.searchUser(
          _commonController.query.value, pageKey);
      final isLastPage = newItems.length < 12;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey++;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    } finally {
      _commonController.isSearchLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? const Color(0xFF102437)
                : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() => Column(children: [
              DeferredPointerHandler(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: AlignmentDirectional.topCenter,
                  fit: StackFit.loose,
                  children: [
                    buildAppBar(),
                    Positioned(
                        top: 110,
                        child: SizedBox(
                          height: 48,
                          width: MediaQuery.of(context).size.width - 24,
                          child: DeferPointer(
                            child: buildFloatingSearchBar(),
                          ),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(top: 38),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _chatController.searchIsActiveInCompose.value
                            ? const SizedBox(
                                height: 0,
                                width: 0,
                              )
                            : Column(
                                children: [
                                  ListTile(
                                      leading: IconButton(
                                        icon: Icon(
                                          Icons.groups,
                                          size: 28,
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        onPressed: () {},
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      tileColor: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? const Color(0xFF113751)
                                          : Colors.white,
                                      title: Text(
                                        "New group",
                                        style: TextStyle(
                                            fontFamily: "Gilroy",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      onTap: () {
                                        _navigationController.hideNavBar.value =
                                            true;
                                        pushNewScreen(context,
                                                screen:
                                                    const CreateGroupFirstScreen())
                                            .then((value) {
                                          _navigationController
                                              .hideNavBar.value = true;
                                        });
                                        _chatController
                                            .sendingMessageMode.value = 1;
                                        _chatController.chipsList.clear();
                                      }),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  ListTile(
                                    leading: IconButton(
                                      icon: Icon(
                                        Icons.volume_up_rounded,
                                        size: 28,
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      onPressed: () {},
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    tileColor: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? const Color(0xFF113751)
                                        : Colors.white,
                                    title: Text(
                                      "New broadcast list",
                                      style: TextStyle(
                                          fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    onTap: () {
                                      _chatController.sendingMessageMode.value =
                                          2;
                                      _chatController.chipsList.clear();
                                    },
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  ListTile(
                                    leading: IconButton(
                                      icon: Image.asset(
                                        "assets/images/add_user.png",
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        width: 22,
                                        height: 22,
                                      ),
                                      onPressed: () {},
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    tileColor: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? const Color(0xFF113751)
                                        : Colors.white,
                                    title: Text(
                                      "Add a user to my SIRKL",
                                      style: TextStyle(
                                          fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    onTap: () {
                                      _chatController.sendingMessageMode.value =
                                          3;
                                      _chatController.chipsList.clear();
                                      pushNewScreen(context,
                                              screen: const AddContactScreen())
                                          .then((value) {
                                        pagingController.refresh();
                                        _commonController.users.refresh();
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ),
                        _chatController.chipsList.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      con.toRes.tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                          fontFamily: "Gilroy",
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    height: 50,
                                    child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            _chatController.chipsList.length,
                                        itemBuilder: buildChip),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                ],
                              )
                            : Container(),
                        _chatController.searchIsActiveInCompose.value
                            ? const SizedBox(
                                height: 0,
                                width: 0,
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  con.contactsRes.tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      fontFamily: "Gilroy",
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                        _commonController.isSearchLoading.value
                            ? Padding(
                                padding: const EdgeInsets.only(top: 48.0),
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: SColors.activeColor,
                                )),
                              )
                            : MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: Expanded(
                                    child: PagedListView.separated(
                                        separatorBuilder: (context, index) {
                                          return const Divider(
                                            color: Color(0xFF828282),
                                            thickness: 0.2,
                                            endIndent: 20,
                                            indent: 86,
                                          );
                                        },
                                        pagingController: pagingController,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        builderDelegate:
                                            PagedChildBuilderDelegate<UserDTO>(
                                                itemBuilder:
                                                    (context, item, index) =>
                                                        buildUserTile(context,
                                                            index, item)))),
                              )
                      ],
                    )),
              ),
              _chatController.sendingMessageMode.value == 2
                  ? buildBottomBar()
                  : const SizedBox(
                      height: 0,
                      width: 0,
                    ),
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
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF113751)
                  : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF1E2032)
                  : Colors.white
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
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  size: 42,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Text(
                  con.newMessageRes.tr,
                  style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              const SizedBox(
                width: 42,
                height: 42,
              )
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
      hint: 'Search username, wallet or ENS',
      backdropColor: Colors.transparent,
      scrollPadding: const EdgeInsets.only(top: 0, bottom: 0),
      transitionDuration: const Duration(milliseconds: 0),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 10.0,
      openAxisAlignment: 10.0,
      queryStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.white
              : Colors.black,
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
      accentColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xFF2D465E).withOpacity(1)
              : Colors.white,
      debounceDelay: const Duration(milliseconds: 200),
      onQueryChanged: (query) async {
        ///Search for ENS
        if (query.isNotEmpty && query.contains('.eth')) {
          _commonController.isSearchLoading.value = true;
          String? ethFromEns = await _chatController.getEthFromEns(
              query, _homeController.userMe.value.wallet!);
          if (_profileController.isUserExists.value == null &&
              ethFromEns != "" &&
              ethFromEns != "0") {
            pagingController.itemList = [
              UserDTO(
                  id: '',
                  userName: query,
                  picture: "",
                  isAdmin: false,
                  createdAt: DateTime.now(),
                  description: '',
                  fcmToken: "",
                  wallet: ethFromEns,
                  following: 0,
                  isInFollowing: false)
            ];
          } else if (_profileController.isUserExists.value != null) {
            pagingController.itemList = [
              _profileController.isUserExists.value!
            ];
          } else {
            pagingController.itemList = [];
          }
          _commonController.isSearchLoading.value = false;
        }

        ///Search for wallet
        else if (query.isNotEmpty &&
            isValidEthereumAddress(query.toLowerCase()) &&
            query.toLowerCase() !=
                _homeController.userMe.value.wallet!.toLowerCase()) {
          _commonController.isSearchLoading.value = true;
          _profileController.isUserExists.value =
              await _profileController.getUserByWallet(query.toLowerCase());
          if (_profileController.isUserExists.value == null) {
            pagingController.itemList = [
              UserDTO(
                  id: '',
                  userName: "",
                  picture: "",
                  isAdmin: false,
                  createdAt: DateTime.now(),
                  description: '',
                  fcmToken: "",
                  wallet: query.toLowerCase(),
                  following: 0,
                  isInFollowing: false)
            ];
          } else {
            pagingController.itemList = [
              _profileController.isUserExists.value!
            ];
          }
          _commonController.isSearchLoading.value = false;
        }

        ///Search by substring
        else {
          pageKey = 0;
          _commonController.query.value = query;
          if (query.isNotEmpty) {
            _chatController.searchIsActiveInCompose.value = true;
            pagingController.itemList = [];
            await fetchPageUsers();
            //pagingController.itemList = await _callController.retrieveUsers(query.toLowerCase(), 0);
          } else {
            _chatController.searchIsActiveInCompose.value = false;
            pagingController.refresh();
          }
        }
      },
      //transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction.icon(
          icon: Image.asset(
            "assets/images/search.png",
            width: 24,
            height: 24,
            color: Colors.grey,
          ),
          showIfClosed: true,
          showIfOpened: true,
          onTap: () {
            if (_chatController.searchIsActiveInCompose.value) {
              _chatController.searchIsActiveInCompose.value = false;
              _searchController.close();
              _chatController.sendingMessageMode.value = 0;
              pagingController.refresh();
            } else {
              _chatController.searchIsActiveInCompose.value = true;
              _searchController.open();
            }
          },
        ),
      ],
      actions: const [],
      builder: (context, transition) {
        return const SizedBox(height: 0);
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
          backgroundColor: SColors.activeColor,
          label: Text(
            _chatController.chipsList[index].userName.isNullOrBlank!
                ? "${_chatController.chipsList[index].wallet!.substring(0, 10)}..."
                : _chatController.chipsList[index].userName!,
            style: const TextStyle(
                fontFamily: "Gilroy",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          )),
    );
  }

  Widget buildUserTile(BuildContext context, int index, UserDTO item) {
    return Obx(() => ListTile(
        onTap: () async {
          if (_chatController.sendingMessageMode.value == 0 ||
              _chatController.sendingMessageMode.value == 3) {
            if (item.id.isNullOrBlank!) {
              var idChannel = DateTime.now().millisecondsSinceEpoch.toString();
              var idChannelCreated = await _chatController.createInbox(
                  InboxCreationDto(
                      isConv: true,
                      isGroupPaying: false,
                      nameEth: _searchController.query.contains("eth")
                          ? _searchController.query
                          : null,
                      createdBy: _homeController.id.value,
                      wallets: [
                        _homeController.userMe.value.wallet!,
                        item.wallet!
                      ],
                      idChannel: idChannel));
              pushNewScreen(context,
                      screen: DetailedChatScreen(
                          create: false, channelId: idChannelCreated))
                  .then((value) {
                Navigator.pop(context);
                _navigationController.hideNavBar.value = false;
              });
            } else {
              _commonController.userClicked.value = item;
              pushNewScreen(context,
                      screen: const DetailedChatScreen(create: true))
                  .then((value) {
                Navigator.pop(context);
                _navigationController.hideNavBar.value = false;
              });
            }
          }
        },
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(90.0),
            child: item.picture == null
                ? SizedBox(
                    width: 56,
                    height: 56,
                    child: TinyAvatar(
                      baseString: item.wallet!,
                      dimension: 56,
                      circular: true,
                      colourScheme: TinyAvatarColourScheme.seascape,
                    ))
                : CachedNetworkImage(
                    imageUrl: item.picture!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                            color: SColors.activeColor)),
                    errorWidget: (context, url, error) =>
                        Image.asset("assets/images/app_icon_rounded.png"))),
        trailing: _chatController.sendingMessageMode.value == 2
            ? Checkbox(
                onChanged: (selected) {
                  if (_chatController.chipsList.value.length == 3 &&
                      _chatController.sendingMessageMode.value == 2 &&
                      selected!) {
                    showToast(context, con.maxUserSelectedRes.tr);
                  } else if (selected!) {
                    _chatController.chipsList.add(item);
                  } else {
                    _chatController.chipsList.removeWhere(
                        (element) => element.wallet == item.wallet);
                  }
                  _chatController.chipsList.refresh();
                },
                value: _chatController.chipsList
                    .map((element) => element.wallet)
                    .contains(item.wallet),
                checkColor: SColors.activeColor,
                fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                side: MaterialStateBorderSide.resolveWith(
                  (states) =>
                      BorderSide(width: 1.0, color: SColors.activeColor),
                ),
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
        title: Transform.translate(
          offset: const Offset(-8, 0),
          child: Text(displayName(item, _homeController),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w600,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black)),
        ),
        subtitle: !item.userName.isNullOrBlank!
            ? Transform.translate(
                offset: const Offset(-8, 0),
                child: Text(
                    "${item.wallet!.substring(0, 6)}...${item.wallet!.substring(item.wallet!.length - 4)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w500,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? const Color(0xFF9BA0A5)
                            : const Color(0xFF828282))),
              )
            : null));
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
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF111D28)
                  : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF1E2032)
                  : Colors.white
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
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282)),
                filled: true,
                fillColor:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF2D465E)
                        : const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Flexible(
            child: InkWell(
              onTap: () async {
                if (_chatController.chipsList.length < 2) {
                  showToast(context, "Please, choose at least 2 participants");
                } else if (_chatController.sendingMessageMode.value == 2 &&
                    _messageInputController.text.isNotEmpty &&
                    !_messageInputController.text.isBlank!) {
                  await sendMessageAsBroadcastList();
                }
              },
              child: _chatController.messageSending.value
                  ? SizedBox(
                      width: 55,
                      height: 55,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: SColors.activeColor,
                        ),
                      ))
                  : Container(
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
      var idChannel = DateTime.now().millisecondsSinceEpoch.toString();
      if (element.id.isNullOrBlank!) {
        idChannelCreated = await _chatController.createInbox(InboxCreationDto(
            isConv: true,
            isGroupPaying: false,
            createdBy: _homeController.id.value,
            wallets: [_homeController.userMe.value.wallet!, element.wallet!],
            idChannel: idChannel,
            message: _messageInputController.text));
      } else {
        await _chatController.createInbox(InboxCreationDto(
            isConv: true,
            createdBy: _homeController.id.value,
            wallets: [_homeController.userMe.value.wallet!, element.wallet!],
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
            pushNewScreen(context,
                    screen: DetailedChatScreen(
                        create: false, channelId: idChannelCreated),
                    withNavBar: false)
                .then(
                    (value) => _navigationController.hideNavBar.value = false);
          } else {
            _commonController.userClicked.value = _chatController.chipsList[0];
            pushNewScreen(context,
                    screen: const DetailedChatScreen(create: true),
                    withNavBar: false)
                .then(
                    (value) => _navigationController.hideNavBar.value = false);
          }
        } else {
          Navigator.pop(context);
        }
      }
    }
    _chatController.chipsList.clear();
  }

  @override
  void dispose() {
    _commonController.isSearchLoading.value = false;
    _chatController.searchIsActiveInCompose.value = false;
    _chatController.sendingMessageMode.value = 0;
    _chatController.chipsList.clear();
    pagingController.dispose();
    _commonController.query.value = "";
    super.dispose();
  }
}
