// ignore_for_file: use_build_context_synchronously, deprecated_member_use, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/config/s_config.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/inbox_controller.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/models/nft_dto.dart';
import 'package:sirkl/models/nickname_creation_dto.dart';
import 'package:sirkl/models/notification_register_dto.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/models/story_dto.dart';
import 'package:sirkl/models/story_modification_dto.dart';
import 'package:sirkl/models/update_fcm_dto.dart';
import 'package:sirkl/models/update_me_dto.dart';
import 'package:sirkl/models/wallet_connect_dto.dart';
import 'package:sirkl/repositories/asset_repo.dart';
import 'package:sirkl/repositories/auth_repo.dart';
import 'package:sirkl/repositories/inbox_repo.dart';
import 'package:sirkl/repositories/nickname_repo.dart';
import 'package:sirkl/repositories/notification_repo.dart';
import 'package:sirkl/repositories/story_repo.dart';
import 'package:sirkl/repositories/user_repo.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

import '../common/save_pref_keys.dart';

class HomeController extends GetxController {
  NavigationController get _navigationController =>
      Get.find<NavigationController>();
  CommonController get _commonController => Get.find<CommonController>();
  InboxController get _chatController => Get.find<InboxController>();

  final box = GetStorage();

  Rx<List<List<StoryDto?>?>?> stories = (null as List<List<StoryDto?>?>?).obs;
  RxList<String> contractAddresses = <String>[].obs;
  Rx<PagingController<int, List<StoryDto?>?>> storyPagingController =
      PagingController<int, List<StoryDto?>?>(firstPageKey: 0).obs;

  var id = "".obs;
  var isConfiguring = false.obs;
  Rx<String> accessToken = "".obs;
  var userMe = UserDTO().obs;
  var userAdded = UserDTO().obs;
  var address = "".obs;
  var indexStory = 0.obs;
  var actualStoryIndex = 0.obs;
  var loadingStories = true.obs;
  var isFirstConnexion = false.obs;
  var pageKey = 0.obs;
  var nicknames = {}.obs;
  var userBlocked = [].obs;
  var isInFav = <String>[].obs;
  var isFavNftSelected = false.obs;
  var qrActive = false.obs;
  var notificationActive = true.obs;
  var streamChatToken = "".obs;
  var isSigning = false.obs;
  var displayPopupFirstConnection = false.obs;
  var isLoading = false.obs;
  var isStoryLoading = false.obs;
  var fetchingAssets = false.obs;

  var isCheckingBetaCode = false.obs;

  /// Function to check if the Beta code is correct
  Future<bool> checkBetaCode(String code) async =>
      await AuthRepo.checkBetaCode(code);

  /// Function to retrieve stored values (as basic values in init)
  retrieveStoredValues() {
    var accessTok = box.read(SharedPref.ACCESS_TOKEN);
    accessToken.value = accessTok ?? '';
    streamChatToken.value = box.read(SharedPref.STREAM_CHAT_TOKEN) ?? "";
    var checkBoxRead = box.read(con.contractAddresses);
    notificationActive.value = box.read(SharedPref.NOTIFICATION_ACTIVE) ?? true;
    if (checkBoxRead != null) {
      contractAddresses.value =
          box.read(con.contractAddresses).cast<String>() ?? [];
    } else {
      contractAddresses.value = [];
    }

    UserDTO user = box.read(SharedPref.USER) != null
        ? UserDTO.fromJson(box.read(SharedPref.USER))
        : UserDTO();

    userMe.value = user;
    id.value = user.id ?? '';
    userBlocked.value = box.read(SharedPref.USER_BLOCKED) ?? [];
  }

  /// Function to switch on/off notification
  switchActiveNotification(bool active) async {
    await box.write(SharedPref.NOTIFICATION_ACTIVE, active);
    notificationActive.value = active;
  }

  /// Function to login with wallet
  loginWithWallet(BuildContext context, String wallet, String message,
      String signature) async {
    SignInSuccessDto signSuccess = await AuthRepo.verifySignature(
        WalletConnectDto(
            wallet: wallet,
            message: message,
            signature: signature,
            platform: defaultTargetPlatform == TargetPlatform.android
                ? "android"
                : "iOS"));

    AppsflyerSdk appsflyerSdk = Get.find<AppsflyerSdk>();
    await appsflyerSdk.logEvent("af_login", {});

    box.write(SharedPref.USER, signSuccess.user!.toJson());
    userMe.value = signSuccess.user!;
    accessToken.value = signSuccess.accessToken;

    isConfiguring.value = true;
    isFirstConnexion.value = true;
    _navigationController.hideNavBar.value = false;
    isLoading.value = false;
    if (DateTime.now().difference(userMe.value.createdAt!).inSeconds < 60) {
      displayPopupFirstConnection.value = true;
    }

    try {
      retrieveContractAddress();
    } catch (e) {
      throw ErrorResponse();
    }
    await getAllNftConfig();
    await connectUserToStream(StreamChat.of(context).client);
    putFCMToken(context, StreamChat.of(context).client, false);
    retrieveInboxes();
  }

  /// Function to store and/or update FCM Token
  Future<void> putFCMToken(
      BuildContext context, StreamChatClient client, bool isLogged) async {
    if (accessToken.value.isNotEmpty) {
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      UserDTO userDTO = await UserRepo.uploadFCMToken(UpdateFcmdto(
          token: fcmToken,
          platform: defaultTargetPlatform == TargetPlatform.android
              ? 'android'
              : 'iOS'));
      userMe.value = userDTO;
      box.write(SharedPref.USER, userDTO.toJson());
      await retrieveNicknames();
      await _commonController.showSirklUsers(id.value);
      await client.addDevice(fcmToken!, PushProvider.firebase,
          pushProviderName: "Firebase_Config");
      if (isLogged) updateAllNftConfig();
      if (Platform.isIOS) {
        var token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
        await UserRepo.uploadAPNToken(token);
      }
      if (!isLogged) {
        try {
          retrieveContractAddress();
        } catch (e) {
          var k = e;
        }
      }
    }
  }

  /// Function to retrieve the contract addresses of the assets own by the user and store them
  retrieveContractAddress() async {
    contractAddresses.value = await AssetRepo.retrieveContactAddress();
    box.write(con.contractAddresses, contractAddresses);
  }

  /// Function called only server side to get and store assets of the user (at login only)
  Future<void> getAllNftConfig() async {
    fetchingAssets.value = true;
    await AssetRepo.getAllNFTConfig();
    fetchingAssets.value = false;
  }

  /// Function called only server side to update assets of the user
  updateAllNftConfig() async => await AssetRepo.updateAllNFTConfig();

  /// Function to retrieve assets of a given user
  Future<List<NftDto>> getAssets(
      String id, bool isFav, int offset, UserDTO? user) async {
    if (offset == 0 && id == this.id.value) isInFav.clear();
    List<NftDto> assets = await AssetRepo.retrieveNFTs(
        id: id, isFav: isFav, offset: offset.toString());

    if (id == this.id.value) {
      if (userMe.value.hasSBT! && offset == 0) {
        assets.add(NftDto(
            id: this.id.value,
            title: "SIRKL Club",
            collectionImage:
                "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png",
            images: [
              "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"
            ],
            contractAddress:
                "0x2B2535Ba07Cd144e143129DcE2dA4f21145a5011".toLowerCase(),
            isFav: false));
      }

      isInFav.addAll(assets
          .where((element) => element.isFav!)
          .map((e) => e.contractAddress!)
          .toList());
    } else {
      if (user != null && (user.hasSBT ?? false) && offset == 0) {
        assets.add(NftDto(
            id: id,
            title: "SIRKL Club",
            collectionImage:
                "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png",
            images: [
              "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"
            ],
            contractAddress:
                "0x2B2535Ba07Cd144e143129DcE2dA4f21145a5011".toLowerCase(),
            isFav: false));
      }
    }
    return assets;
  }

  /// Function to update the user
  // TODO : Check if not duplicate and delete in that case
  updateMe(UpdateMeDto updateMeDto) async {
    UserDTO userDto = await UserRepo.modifyUser(updateMeDto);
    box.write(SharedPref.USER, userDto.toJson());
    userMe.value = userDto;
  }

  /// Function to update a story (mainly to update users that have seen it)
  updateStory(StoryModificationDto storyModificationDto) async {
    await StoryRepo.updateStory(storyModificationDto);
    stories.value?[actualStoryIndex.value]
        ?.where((element) => element?.id == storyModificationDto.id)
        .first
        ?.readers = storyModificationDto.readers;
    stories.refresh();
  }

  /// Function to delete a story
  Future<void> deleteStory(String createdBy, String id) async =>
      await StoryRepo.deleteStory(createdBy: createdBy, id: id);

  /// Function to receive the welcome message from SIRKL.io at first connexion
  Future<void> getWelcomeMessage() async =>
      await UserRepo.receiveWelcomeMessage();

  /// Function to give or update a nickname
  updateNickname(String wallet, String nickname) async {
    if (nicknames[wallet] != nickname) {
      nicknames[wallet] = nickname;
      nicknames.refresh();
      _commonController.users.refresh();

      await NicknameRepo.updateNicknames(
          wallet: wallet, nickNameDto: NicknameCreationDto(nickname: nickname));
    }
  }

  /// Connect user to Stream Chat
  Future<void> connectUserToStream(StreamChatClient client) async {
    retrieveStoredValues();

    if (accessToken.value.isNotEmpty) {
      if (client.wsConnectionStatus != ConnectionStatus.connected) {
        if (streamChatToken.value.isNullOrBlank!) {
          await _handleNewUser(client);
        } else {
          await _handleExistingUser(client);
        }

        isConfiguring.value = false;
        isFirstConnexion.value = false;
        await checkIfHasMessage(client);
      }
    }
  }

  /// Helper function to connect user to stream if new one
  Future<void> _handleNewUser(StreamChatClient client) async {
    String token = await UserRepo.retrieveTokenStreamChat();

    var userToPass = UserDTO(
      id: userMe.value.id,
      userName: userMe.value.userName,
      picture: userMe.value.picture,
      isAdmin: userMe.value.isAdmin,
      createdAt: userMe.value.createdAt,
      description: userMe.value.description,
      fcmToken: userMe.value.fcmToken,
      wallet: userMe.value.wallet,
      following: userMe.value.following,
      isInFollowing: userMe.value.isInFollowing,
    );

    try {
      await client.connectUser(
        User(id: userMe.value.id!, extraData: {"userDTO": userToPass.toJson()}),
        token,
      );

      if (DateTime.now().difference(userMe.value.createdAt!) <
          const Duration(minutes: 1)) {
        await _commonController.addUserToSirkl(
            SConfig.SIRKL_ID, client, userMe.value.id!);
        await getWelcomeMessage();
      }

      await box.write(SharedPref.STREAM_CHAT_TOKEN, token);
      streamChatToken.value = token;
    } catch (e) {
      debugPrint("ERROR_CONNECTION");
    }
  }

  /// Helper function to connect user to stream if already existing
  Future<void> _handleExistingUser(StreamChatClient client) async {
    if (streamChatToken.value.isNullOrBlank!) {
      String token = await UserRepo.retrieveTokenStreamChat();
      streamChatToken.value = token;
      await box.write(SharedPref.STREAM_CHAT_TOKEN, token);
    }

    await client.connectUser(User(id: userMe.value.id!), streamChatToken.value);
  }

  /// Function to retrieve nicknames
  retrieveNicknames() async {
    Map<dynamic, dynamic> names = await NicknameRepo.retrieveNicknames();
    nicknames.value = names;
  }

  /// Function to retrieve stories
  Future<List<List<StoryDto>>> retrieveStories(int offset) async {
    if (offset == 0) {
      stories.value?.clear();
      pageKey.value = 0;
    }

    List<List<StoryDto>> retrievedStories =
        await StoryRepo.retrieveStories(offset.toString());

    loadingStories.value = false;
    if (stories.value == null) {
      stories.value = retrievedStories;
    } else {
      stories.value = stories.value! + retrievedStories;
    }
    return retrievedStories;
  }

  /// Function to retrieve inbox (if user is new, check if someone sent him
  /// messages on his wallet, and create stream chat)
  retrieveInboxes() async => await InboxRepo.updateInbox();

  /// Function to register notification
  checkOfflineNotificationAndRegister() async {
    var notifications = GetStorage().read(con.notificationSaved) ?? [];
    var notificationsToDelete = [];
    for (var notification in (notifications as List<dynamic>)) {
      await NotificationRepo.registerNotification(
          NotificationRegisterDto(message: notification));
      notificationsToDelete.add(notification);
    }
    var notificationsToSave = notifications
        .toSet()
        .difference(notificationsToDelete.toSet())
        .toList();
    await GetStorage().write(con.notificationSaved, notificationsToSave);
  }

  /// Function checking if user has unread message(s)
  checkIfHasMessage(StreamChatClient client) async {
    client
        .queryChannels(
            filter: Filter.and([
              Filter.equal("type", "try"),
              Filter.or([
                Filter.in_("members", [id.value]),
                Filter.equal("created_by_id", id.value),
              ]),
              Filter.or([
                Filter.and([
                  Filter.greater(
                      "last_message_at", "2022-11-23T12:00:18.54912Z"),
                  Filter.exists("${id.value}_follow_channel"),
                  Filter.equal("${id.value}_follow_channel", true),
                  Filter.equal('isConv', true),
                ]),
                Filter.equal('isConv', false),
              ]),
            ]),
            paginationParams: const PaginationParams(limit: 1))
        .listen((event) {
      if (event.first.state != null && event.first.state!.unreadCount > 0) {
        _chatController.index.value = 0;
        _navigationController.controller.value.index = 3;
      } else {
        client
            .queryChannels(
                filter: Filter.and([
                  Filter.equal("type", "try"),
                  Filter.greater(
                      "last_message_at", "2022-11-23T12:00:18.54912Z"),
                  Filter.equal('isConv', true),
                  Filter.or([
                    Filter.equal("created_by_id", id.value),
                    Filter.in_("members", [id.value]),
                  ]),
                  Filter.or([
                    Filter.notExists("${id.value}_follow_channel"),
                    Filter.equal("${id.value}_follow_channel", false)
                  ])
                ]),
                paginationParams: const PaginationParams(limit: 1))
            .listen((event) {
          if (event.isNotEmpty &&
              event.first.state != null &&
              event.first.state!.unreadCount > 0) {
            _chatController.index.value = 1;
            _navigationController.controller.value.index = 3;
          }
        });
      }
    });
  }
}

isNumeric(string) => num.tryParse(string) != null;
