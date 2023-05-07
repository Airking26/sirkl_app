// ignore_for_file: use_build_context_synchronously, deprecated_member_use, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/chats/service/chats_service.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/contract_address_dto.dart';
import 'package:sirkl/common/model/nft_alchemy_dto.dart';
import 'package:sirkl/common/model/nft_dto.dart';
import 'package:sirkl/common/model/nickname_creation_dto.dart';
import 'package:sirkl/common/model/notification_register_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/story_dto.dart';
import 'package:sirkl/common/model/story_modification_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/model/wallet_connect_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/service/profile_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:web3dart/crypto.dart';

import '../../common/model/refresh_token_dto.dart';
import '../../common/model/update_fcm_dto.dart';

class HomeController extends GetxController{

  final HomeService _homeService = HomeService();
  final ProfileService _profileService = ProfileService();
  final ChatsService _chatService = ChatsService();

  final _navigationController = Get.put(NavigationController());
  final _commonController = Get.put(CommonController());

  final box = GetStorage();

  var sessionStatus;
  var _uri;

  Rx<List<List<StoryDto?>?>?> stories = (null as List<List<StoryDto?>?>?).obs;
  RxList<String> contractAddresses = <String>[].obs;
  Rx<PagingController<int, List<StoryDto?>?>> pagingController = PagingController<int, List<StoryDto?>?>(firstPageKey: 0).obs;

  var id = "".obs;
  var isConfiguring = false.obs;
  var accessToken = "".obs;
  var userMe = UserDTO().obs;
  var userAdded = UserDTO().obs;
  var nicknameUser = "".obs;
  var isLoadingNfts = true.obs;
  var address = "".obs;
  var indexStory = 0.obs;
  var actualStoryIndex = 0.obs;
  var controllerConnected = false.obs;
  var loadingStories = true.obs;
  var pageKey = 0.obs;
  var nicknames = {}.obs;
  var userBlocked = [].obs;
  var iHaveNft = false.obs;
  var heHasNft = false.obs;
  var isInFav = <String>[].obs;
  var isFavNftSelected = false.obs;
  var qrActive = false.obs;
  var notificationActive = true.obs;

  final connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
      name: 'SIRKL',
      description: 'SIRKL Login',
      url: 'https://walletconnect.org',
      icons: [
        'https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png'
      ],
    ),
  );

  retrieveAccessToken(){
    var accessTok = box.read(con.ACCESS_TOKEN);
    accessToken.value = accessTok ?? '';
    var checkBoxRead = box.read(con.contractAddresses);
    notificationActive.value = box.read(con.NOTIFICATION_ACTIVE) ?? true;
    if(checkBoxRead != null) {
      contractAddresses.value = box.read(con.contractAddresses).cast<String>() ?? [];
    } else {
      contractAddresses.value = [];
    }
    var user = box.read(con.USER);
    userMe.value = user != null ? userFromJson(box.read(con.USER) ?? "") : UserDTO();
    id.value = user != null ? userFromJson(box.read(con.USER) ?? "").id ?? "": "";
    userBlocked.value = box.read(con.USER_BLOCKED) ?? [];
  }

  switchActiveNotification(bool active) async{
    await box.write(con.NOTIFICATION_ACTIVE, active);
    notificationActive.value = active;
  }

  connectWallet(BuildContext context) async {

    connector.on('connect', (session) async{
      address.value = sessionStatus?.accounts[0];
    });

    connector.on('session_request', (payload) {
    });

    connector.on('disconnect', (session) {
    });

    if (!connector.connected) {
      sessionStatus = await connector.createSession(
        chainId: 4160,
        onDisplayUri: (uri) async {
          _uri = uri;
          try{
            var t = await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
            if(t == false) {
              Fluttertoast.showToast(
                msg: "Not wallet was found, please create one in order to continue",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 2,
                backgroundColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF102437) ,
                textColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.black : Colors.white,
                fontSize: 16.0
            );
            }
          } on Exception {
            debugPrint("II");
            Fluttertoast.showToast(
                msg: "Not wallet was found, please create one in order to continue",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 10,
                backgroundColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF102437) ,
                textColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.black : Colors.white,
                fontSize: 16.0
            );
          }
        },
      );
    }
  }

  String generateSessionMessage(String accountAddress) {
    String message = 'Hello $accountAddress, welcome to our app. By signing this message you agree to learn and have fun with blockchain';
    var hash = keccakUtf8(message);
    final hashString = '0x${bytesToHex(hash).toString()}';

    return hashString;
  }

  signMessageWithMetamask(BuildContext context) async {
    if (connector.connected) {
      try {
        var message = generateSessionMessage(address.value);
        EthereumWalletConnectProvider provider =
        EthereumWalletConnectProvider(connector);
        launchUrlString(_uri, mode: LaunchMode.externalApplication);
        var signature = await provider.personalSign(message: message, address: address.value, password: "");
        await loginWithWallet(context, address.value, message, signature);
      } catch (exp) {
        if (kDebugMode) {
          print(exp);
        }
      }
    }
  }
  loginWithWallet(BuildContext context, String wallet, String message, String signature) async{
    var request = await _homeService.verifySignature(walletConnectDtoToJson(WalletConnectDto(wallet: wallet, message: message, signature: signature, platform: defaultTargetPlatform == TargetPlatform.android
        ? "android": "iOS")));
    if(request.isOk){
      _navigationController.hideNavBar.value = false;
      var signSuccess = signInSuccessDtoFromJson(json.encode(request.body));
      userMe.value = signSuccess.user!;
      box.write(con.ACCESS_TOKEN, signSuccess.accessToken!);
      accessToken.value = signSuccess.accessToken!;
      box.write(con.REFRESH_TOKEN, signSuccess.refreshToken!);
      box.write(con.USER, userToJson(signSuccess.user!));
      isConfiguring.value = true;
      await putFCMToken(context, StreamChat.of(context).client, false);
      await getAllNftConfig();
      await retrieveInboxes();
    }
  }

  putFCMToken(BuildContext context, StreamChatClient client,bool isLogged) async {
    retrieveAccessToken();
    if(accessToken.value.isNotEmpty) {
      final firebaseMessaging = await FirebaseMessaging.instance.getToken();
      var accessToken = box.read(con.ACCESS_TOKEN);
      var refreshToken = box.read(con.REFRESH_TOKEN);
      var fcm = defaultTargetPlatform == TargetPlatform.android
          ? updateFcmdtoToJson(
          UpdateFcmdto(token: firebaseMessaging, platform: 'android'))
          : updateFcmdtoToJson(
          UpdateFcmdto(token: firebaseMessaging, platform: 'iOS'));
      var request = await _homeService.uploadFCMToken(accessToken!, fcm);
      if (request.statusCode == 401) {
        var requestToken = await _homeService.refreshToken(refreshToken!);
        var refreshTokenDto = refreshTokenDtoFromJson(
            json.encode(requestToken.body));
        accessToken = refreshTokenDto.accessToken!;
        box.write(con.ACCESS_TOKEN, accessToken);
        request = await _homeService.uploadFCMToken(accessToken, fcm);
        if(request.isOk){
          userMe.value = userFromJson(json.encode(request.body));
          box.write(con.USER, userToJson(userFromJson(json.encode(request.body))));
          retrieveAccessToken();
          if(isLogged) updateAllNftConfig();
          await retrieveTokenStreamChat(client, firebaseMessaging!);
          await retrieveNicknames();
          await _commonController.showSirklUsers(id.value);
          if(Platform.isIOS) {
            var token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
            await _homeService.uploadAPNToken(accessToken, token);
          }
          await getNFTsContractAddresses(client, userMe.value.wallet!);
        }
      } else if(request.isOk){
        userMe.value = userFromJson(json.encode(request.body));
        box.write(con.USER, userToJson(userFromJson(json.encode(request.body))));
        retrieveAccessToken();
        if(isLogged) updateAllNftConfig();
        await retrieveTokenStreamChat(client, firebaseMessaging!);
        await retrieveNicknames();
        await _commonController.showSirklUsers(id.value);
        if(Platform.isIOS) {
          var token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
          await _homeService.uploadAPNToken(accessToken, token);
        }
        await getNFTsContractAddresses(client, userMe.value.wallet!);
      } else {
        debugPrint(request.statusText);
        debugPrint(request.bodyString);
      }
    }
  }

  getNFTsContractAddresses(StreamChatClient? client, String wallet) async{
    var stockedContractAddresses = box.read(con.contractAddresses) ?? [];
    var req = await _homeService.getContractAddressesWithAlchemy(wallet, "");
    if(req.body != null){
    var initialArray = contractAddressDtoFromJson(json.encode(req.body)).contracts!;
    if(contractAddressDtoFromJson(json.encode(req.body)).pageKey != null) {
      var cursor = contractAddressDtoFromJson(json.encode(req.body)).pageKey;
      while (cursor != null) {
        var newReq = await _homeService.getContractAddressesWithAlchemy(wallet, "&pageKey=$cursor");
        initialArray.addAll(contractAddressDtoFromJson(json.encode(newReq.body)).contracts!);
        cursor = contractAddressDtoFromJson(json.encode(newReq.body)).pageKey;
      }
    }

    initialArray.removeWhere((element) => element.title == null || element.title!.isEmpty || element.opensea == null || element.opensea!.imageUrl == null || element.opensea!.imageUrl!.isEmpty  ||  element.opensea!.collectionName == null || element.opensea!.collectionName!.isEmpty || element.tokenType == TokenType.UNKNOWN || (element.tokenType == TokenType.ERC1155 && element.opensea?.safelistRequestStatus == SafelistRequestStatus.NOT_REQUESTED));

     for (var element in initialArray) {
       if(!contractAddresses.contains(element.address?.toLowerCase())) contractAddresses.add(element.address!.toLowerCase());
     }

      var addressesAbsent = stockedContractAddresses.toSet().difference(contractAddresses.toSet()).toList();
      if(client != null && addressesAbsent.isNotEmpty) {
        for (var absentAddress in addressesAbsent) {
          await client.removeChannelMembers(absentAddress.toLowerCase(), "try", [id.value]);
        }
      }

      box.write(con.contractAddresses, contractAddresses);
    }
  }

  getAllNftConfig() async{
    await _homeService.getAllNFTConfig(accessToken.value);
  }
  updateAllNftConfig() {
    _homeService.updateAllNFTConfig(accessToken.value);
  }

  getNFT(String id, bool isFav, int offset) async{
    if(offset == 0) isInFav.clear();
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    Response<List<dynamic>> request;
    try{
      request = await _homeService.retrieveNFTs(accessToken, id, isFav, offset.toString());
    } on Error {
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _homeService.retrieveNFTs(accessToken, id, isFav, offset.toString());
    }

    if(request.isOk){
      if(request.body != null && request.body!.isNotEmpty){
        if(id == this.id.value) {
          iHaveNft.value = true;
        } else {
          heHasNft.value = true;
        }
      }
      var nft = nftDtoFromJson(json.encode(request.body));
      isInFav.addAll(nft.where((element) => element.isFav!).map((e) => e.contractAddress!).toList());
     return nft;
    }
  }

  updateMe(UpdateMeDto updateMeDto) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.modifyUser(
        accessToken, updateMeDtoToJson(updateMeDto));
    if (request.statusCode == 401) {
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.modifyUser(
          accessToken, updateMeDtoToJson(updateMeDto));
      if (request.isOk) {
        userMe.value = userFromJson(json.encode(request.body));
      }}
    else if (request.isOk) {
      userMe.value = userFromJson(json.encode(request.body));
    }
  }
  updateStory(StoryModificationDto storyModificationDto) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _homeService.updateStory(accessToken, storyModificationDtoToJson(storyModificationDto));
    if(request.statusCode == 401) {
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _homeService.updateStory(accessToken, storyModificationDtoToJson(storyModificationDto));
      if(request.isOk) {
        stories.value?[actualStoryIndex.value]?.where((element) => element?.id == storyModificationDto.id).first?.readers = storyModificationDto.readers;
        stories.refresh();
      }
    } else if(request.isOk) {
      stories.value?[actualStoryIndex.value]?.where((element) => element?.id == storyModificationDto.id).first?.readers = storyModificationDto.readers;
      stories.refresh();
    }
  }
  updateNickname(String wallet, String nickname) async {
    if(nicknames[wallet] != nickname) {
      nicknames[wallet] = nickname;
      nicknames.refresh();
      _commonController.users.refresh();
      var accessToken = box.read(con.ACCESS_TOKEN);
      var refreshToken = box.read(con.REFRESH_TOKEN);
      var request = await _homeService.updateNicknames(
          accessToken, wallet, nicknameCreationDtoToJson(NicknameCreationDto(nickname: nickname)));
      if (request.statusCode == 401) {
        var requestToken = await _homeService.refreshToken(refreshToken);
        var refreshTokenDTO = refreshTokenDtoFromJson(
            json.encode(requestToken.body));
        accessToken = refreshTokenDTO.accessToken!;
        box.write(con.ACCESS_TOKEN, accessToken);
        await _homeService.updateNicknames(accessToken, wallet, nicknameCreationDtoToJson(NicknameCreationDto(nickname: nickname)));
      }
    }
  }

  getWelcomeMessage() async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _homeService.receiveWelcomeMessage(accessToken);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _homeService.receiveWelcomeMessage(accessToken);
    }
  }

  Future<void> retrieveTokenStreamChat(StreamChatClient client, String? firebaseMessaging) async{
    if(client.wsConnectionStatus != ConnectionStatus.connected) {
      var accessToken = box.read(con.ACCESS_TOKEN);
      var refreshToken = box.read(con.REFRESH_TOKEN);
      var request = await _profileService.retrieveTokenStreamChat(accessToken);
      var userToPass = UserDTO(id: userMe.value.id, userName: userMe.value.userName, picture: userMe.value.picture, isAdmin: userMe.value.isAdmin, createdAt: userMe.value.createdAt, description: userMe.value.description, fcmToken: userMe.value.fcmToken, wallet: userMe.value.wallet, following: userMe.value.following, isInFollowing: userMe.value.isInFollowing);
      if (request.statusCode == 401) {
        var requestToken = await _homeService.refreshToken(refreshToken);
        var refreshTokenDTO = refreshTokenDtoFromJson(
            json.encode(requestToken.body));
        accessToken = refreshTokenDTO.accessToken!;
        box.write(con.ACCESS_TOKEN, accessToken);
        request = await _profileService.retrieveTokenStreamChat(accessToken);
        if (request.isOk) {
          await client.connectUser(User(id: id.value,
              name: userMe.value.userName.isNullOrBlank!
                  ? userMe.value.wallet
                  : userMe.value.userName!,
              extraData: {"userDTO": userToPass}), request.body! );
          controllerConnected.value = true;
          if (firebaseMessaging != null) {
            await client.addDevice(
                firebaseMessaging, PushProvider.firebase,
                pushProviderName: "Firebase_Config");
          }
          if(DateTime.now().difference(userMe.value.createdAt!) < const Duration(minutes: 1)){
            await _commonController.addUserToSirkl("63f78a6188f7d4001f68699a", client, id.value);
            await getWelcomeMessage();
          }
        }
      } else if (request.isOk) {
        await client.connectUser(User(id: id.value,
            name: userMe.value.userName.isNullOrBlank!
                ? userMe.value.wallet
                : userMe.value.userName!,
            extraData: {"userDTO": userToPass}), request.body!);
        controllerConnected.value = true;
        if (firebaseMessaging != null) {
          await client.addDevice(
              firebaseMessaging, PushProvider.firebase,
              pushProviderName: "Firebase_Config");
        }
        if(DateTime.now().difference(userMe.value.createdAt!) < const Duration(minutes: 1)){
          await _commonController.addUserToSirkl("63f78a6188f7d4001f68699a", client, id.value);
          await getWelcomeMessage();
        }
      }
    }
  }
  retrieveNicknames() async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _homeService.retrieveNicknames(accessToken);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      if(request.isOk) nicknames.value = request.body!;
    } else if(request.isOk) {
      nicknames.value = request.body!;
    }
  }
  retrieveStories(int offset) async {
    if(offset == 0) stories.value?.clear();
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    Response<List> request;
    try{
      request = await _homeService.retrieveStories(accessToken, offset.toString());
    } on Error{
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request =  await _homeService.retrieveStories(accessToken, offset.toString());
    }
    if(request.isOk) {
      loadingStories.value = false;
      if(stories.value == null) {
        stories.value = storyDtoFromJson(json.encode(request.body));
      } else {
        stories.value = stories.value! + storyDtoFromJson(json.encode(request.body));
      }
      return storyDtoFromJson(json.encode(request.body));
    } else {
      loadingStories.value = false;
    }
  }
  retrieveInboxes() async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _chatService.walletsToMessages(accessToken);
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _chatService.walletsToMessages(accessToken);
      if(req.isOk) {
        isConfiguring.value = false;
      } else {
        isConfiguring.value = false;
      }
    } else if(req.isOk) {
      isConfiguring.value = false;
    } else {
      isConfiguring.value = false;
    }
  }

  registerNotification(NotificationRegisterDto notificationRegisterDto) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _homeService.registerNotification(accessToken, notificationRegisterDtoToJson(notificationRegisterDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      request = await _homeService.registerNotification(accessToken, notificationRegisterDtoToJson(notificationRegisterDto));
    }
  }

  checkOfflineNotifAndRegister() async {
    var notifications = GetStorage().read(con.notificationSaved) ?? [];
    var notificationsToDelete = [];
    for (var notification in (notifications as List<dynamic>)) {
      await registerNotification(NotificationRegisterDto(message: notification));
      notificationsToDelete.add(notification);
    }
    var notificationsToSave = notifications.toSet().difference(notificationsToDelete.toSet()).toList();
    await GetStorage().write(con.notificationSaved, notificationsToSave);
  }

}