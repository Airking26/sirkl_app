// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:sirkl/common/constants.dart' as con;

import '../../navigation/controller/navigation_controller.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({Key? key}) : super(key: key);

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _profileController = Get.put(ProfileController());
  final _chatController = Get.put(ChatsController());
  final _callController = Get.put(CallsController());
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final nicknameController = TextEditingController();
  final userController = TextEditingController();
  final _utils = Utils();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xFF102437)
              : const Color.fromARGB(255, 247, 253, 255),
      body: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAppbar(context),
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _chatController.contactAddIsEmpty.value
                      ? "Add a user"
                      : "User",
                  style: const TextStyle(fontFamily: "Gilroy", fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              _chatController.contactAddIsEmpty.value
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TypeAheadField(
                        hideOnLoading: true,
                        hideOnError: true,
                        suggestionsBoxDecoration: SuggestionsBoxDecoration(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color(0xFF2D465E)
                                : Colors.white),
                        textFieldConfiguration: TextFieldConfiguration(
                            controller: userController,
                            //enabled: _chatController.contactAddIsEmpty.value,
                            cursorColor: const Color(0xFF00CB7D),
                            autofocus: true,
                            style: DefaultTextStyle.of(context).style.copyWith(
                                fontStyle: FontStyle.normal,
                                fontFamily: "Gilroy"),
                            decoration: InputDecoration(
                                hintText:
                                "Paste a wallet, an ENS or a username",
                                hintStyle:
                                    const TextStyle(fontFamily: "Gilroy"),
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? const Color(0xFF2D465E)
                                          : Colors.white,
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(5.0),
                                ))),
                        suggestionsCallback: (pattern) async =>
                            await _callController.retrieveUsers(pattern, 0),
                        itemBuilder: (context, UserDTO suggestion) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: ClipOval(
                                child: SizedBox.fromSize(
                                  size: const Size.fromRadius(24),
                                  child: suggestion.picture == null
                                      ? TinyAvatar(
                                          baseString: suggestion.wallet!,
                                          dimension: 42,
                                          circular: true,
                                          colourScheme:
                                              TinyAvatarColourScheme.seascape)
                                      : CachedNetworkImage(
                                          imageUrl: suggestion.picture!,
                                          color: Colors.white.withOpacity(0.0),
                                          fit: BoxFit.cover,
                                          colorBlendMode: BlendMode.difference,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Color(
                                                              0xff00CB7D))),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                  "assets/images/app_icon_rounded.png")),
                                ),
                              ),
                              title: Text(
                                suggestion.userName.isNullOrBlank!
                                    ? suggestion.wallet!
                                    : suggestion.userName!,
                                style: const TextStyle(fontFamily: "Gilroy"),
                              ),
                              subtitle: suggestion.userName.isNullOrBlank!
                                  ? const SizedBox()
                                  : Text('${(suggestion).wallet}',
                                      style: const TextStyle(
                                          fontFamily: "Gilroy")),
                            ),
                          );
                        },
                        onSuggestionSelected: (UserDTO suggestion) {
                          userController.text = suggestion.wallet!;
                          _chatController.contactAddIsEmpty.value = false;
                          _homeController.userAdded.value = suggestion;
                        },
                      ))
                  : ListTile(
                      leading: _homeController.userAdded.value.picture == null
                          ? SizedBox(
                              width: 56,
                              height: 56,
                              child: TinyAvatar(
                                baseString:
                                    _homeController.userAdded.value.wallet!,
                                dimension: 56,
                                circular: true,
                                colourScheme: TinyAvatarColourScheme.seascape,
                              ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(90.0),
                              child: CachedNetworkImage(
                                  imageUrl:
                                      _homeController.userAdded.value.picture!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                          color: Color(0xff00CB7D))),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                          "assets/images/app_icon_rounded.png"))),
                      trailing: IconButton(
                          onPressed: () {
                            userController.clear();
                            _chatController.contactAddIsEmpty.value = true;
                            _homeController.userAdded.value = UserDTO();
                          },
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.grey,
                          )),
                      title: Transform.translate(
                          offset: const Offset(-8, 0),
                          child: Text(
                              _homeController
                                      .userAdded.value.nickname.isNullOrBlank!
                                  ? (_homeController.userAdded.value.userName
                                          .isNullOrBlank!
                                      ? "${_homeController.userAdded.value.wallet!.substring(0, 6)}...${_homeController.userAdded.value.wallet!.substring(_homeController.userAdded.value.wallet!.length)}"
                                      : _homeController
                                          .userAdded.value.userName!)
                                  : _homeController.userAdded.value.nickname! +
                                      (_homeController.userAdded.value.userName
                                              .isNullOrBlank!
                                          ? ""
                                          : " (${_homeController.userAdded.value.userName!})"),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Gilroy",
                                  fontWeight: FontWeight.w600,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black))),
                      subtitle: !_homeController
                              .userAdded.value.userName.isNullOrBlank!
                          ? Transform.translate(
                              offset: const Offset(-8, 0),
                              child: Text(
                                  "${_homeController.userAdded.value.wallet!.substring(0, 6)}...${_homeController.userAdded.value.wallet!.substring(_homeController.userAdded.value.wallet!.length - 4)}",
                                  //maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: "Gilroy",
                                      fontWeight: FontWeight.w500,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? const Color(0xFF9BA0A5)
                                          : const Color(0xFF828282))))
                          : null,
                    ),
              const SizedBox(
                height: 32,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Add a nickname (Optional)",
                  style: TextStyle(fontFamily: "Gilroy", fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: nicknameController,
                  style: DefaultTextStyle.of(context).style.copyWith(
                      fontStyle: FontStyle.normal, fontFamily: "Gilroy"),
                  decoration: InputDecoration(
                      hintText: 'Only you will see it',
                      hintStyle: const TextStyle(fontFamily: "Gilroy"),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? const Color(0xFF2D465E).withOpacity(1)
                                : Colors.white,
                            width: 1.5),
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
              )
            ],
          )),
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
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF113751)
                  : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF1E2032)
                  : Colors.white
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey, fontFamily: "Gilroy"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  "New Contact",
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
              TextButton(
                onPressed: () async {
                  if (_chatController.contactAddIsEmpty.value) {
                    _utils.showToast(context, "Please enter a valid user");
                  } else {
                    if(nicknameController.text.isNotEmpty){
                      await _profileController.updateMe(UpdateMeDto(nicknames: {_homeController.userAdded.value.wallet! : nicknameController.text}), StreamChat.of(context).client);
                      _homeController.updateNickname(_homeController.userAdded.value.wallet!, nicknameController.text);
                    }
                    if(await _commonController.addUserToSirkl(_homeController.userAdded.value.id!, StreamChat.of(context).client, _homeController.id.value)){
                        _utils.showToast(context, con.userAddedToSirklRes.trParams({"user": _homeController.userAdded.value.userName ?? _homeController.userAdded.value.wallet!}));
                        nicknameController.clear();
                        userController.clear();
                        _chatController.contactAddIsEmpty.value = true;
                        _homeController.userAdded.value = UserDTO();
                        Navigator.pop(context);
                    } else {
                      _utils.showToast(context, "This user is already in your SIRKL");
                    }
                  }
                },
                child: _commonController.contactAddLoading.value ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xff00CB7D),)) : Text(
                  "Add",
                  style: TextStyle(
                    color: _chatController.contactAddIsEmpty.value
                        ? Colors.grey
                        : const Color(0xff00CB7D),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeController.userAdded.value = UserDTO();
    _chatController.contactAddIsEmpty.value = true;
    nicknameController.clear();
    nicknameController.dispose();
    super.dispose();
  }
}