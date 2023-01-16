import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/chats/service/chats_service.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/collection_dto.dart';
import 'package:sirkl/common/model/moralis_metadata_dto.dart';
import 'package:sirkl/common/model/moralis_nft_contract_addresse.dart';
import 'package:sirkl/common/model/moralis_root_dto.dart';
import 'package:sirkl/common/model/nft_alchemy_dto.dart';
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

  Rx<List<List<StoryDto?>?>?> stories = (null as List<List<StoryDto?>?>?).obs;
  final box = GetStorage();

  var id = "".obs;
  var indexBarHeight = 400.0.obs;
  var isConfiguring = false.obs;
  var accessToken = "".obs;
  var userMe = UserDTO().obs;
  var isLoadingNfts = true.obs;
  var address = "".obs;
  var isUserExists = false.obs;
  var nfts = <CollectionDbDto>[].obs;
  var signPage = false.obs;
  var indexStory = 0.obs;
  var actualStoryIndex = 0.obs;
  var controllerConnected = false.obs;
  var loadingStories = true.obs;
  var sessionStatus;
  var _uri;
  RxList<String> contractAddresses = <String>[].obs;
  var cursor = "".obs;
  var cursorElse = "".obs;
  Rx<PagingController<int, List<StoryDto?>?>> pagingController = PagingController<int, List<StoryDto?>?>(firstPageKey: 0).obs;
  var pageKey = 0.obs;
  var nicknames = {}.obs;

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

  connectWallet(BuildContext context) async {

    connector.on('connect', (session) async{
      address.value = sessionStatus?.accounts[0];
      signPage.value = true;
    });

    connector.on('session_request', (payload) {});

    connector.on('disconnect', (session) {
    });

    if (!connector.connected) {
      sessionStatus = await connector.createSession(
        chainId: 4160,
        onDisplayUri: (uri) async {
          _uri = uri;
          await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
        },
      );
    }
  }

  String generateSessionMessage(String accountAddress) {
    String message =
        'Hello $accountAddress, welcome to our app. By signing this message you agree to learn and have fun with blockchain';
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
        // ignore: use_build_context_synchronously
        await loginWithWallet(context, address.value, message, signature);
      } catch (exp) {
        if (kDebugMode) {
          print(exp);
        }
      }
    }
  }

  loginWithWallet(BuildContext context, String wallet, String message, String signature) async{
    var request = await _homeService.verifySignature(walletConnectDtoToJson(WalletConnectDto(wallet: wallet, message: message, signature: signature)));
    if(request.isOk){
      _navigationController.hideNavBar.value = false;
      var signSuccess = signInSuccessDtoFromJson(json.encode(request.body));
      userMe.value = signSuccess.user!;
      box.write(con.ACCESS_TOKEN, signSuccess.accessToken!);
      accessToken.value = signSuccess.accessToken!;
      box.write(con.REFRESH_TOKEN, signSuccess.refreshToken!);
      box.write(con.USER, userToJson(signSuccess.user!));
      isConfiguring.value = true;
      // ignore: use_build_context_synchronously
      await putFCMToken(context, StreamChat.of(context).client);
      await retrieveInboxes();
    }
  }

  putFCMToken(BuildContext context, StreamChatClient client) async {
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
          await retrieveTokenStreamChat(client, firebaseMessaging!);
          await retrieveNicknames();
          _commonController.showSirklUsers(id.value);
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
        await retrieveTokenStreamChat(client, firebaseMessaging!);
        await retrieveNicknames();
        _commonController.showSirklUsers(id.value);
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

  retrieveAccessToken(){
    var accessTok = box.read(con.ACCESS_TOKEN);
    accessToken.value = accessTok ?? '';
    var checkBoxRead = box.read(con.contractAddresses);
    if(checkBoxRead != null) {
      contractAddresses.value = box.read(con.contractAddresses).cast<String>() ?? [];
    } else {
      contractAddresses.value = [];
    }
    var d = box.read(con.USER);
    userMe.value = d != null ? userFromJson(box.read(con.USER) ?? "") : UserDTO();
    id.value = d != null ? userFromJson(box.read(con.USER) ?? "").id ?? "": "";
  }

  getNFTsContractAddresses(StreamChatClient? client, String wallet) async{
    var stockedContractAddresses = box.read(con.contractAddresses) ?? [];
    var req = await _homeService.getNFTsContractAddresses("0x9aB328b9d8ece399e629Db772F73edFc8ddB244E");
    if(req.body != null){
    var initialArray = moralisNftContractAdressesFromJson(json.encode(req.body)).result!;
    if(moralisNftContractAdressesFromJson(json.encode(req.body)).cursor != null) {
      var cursor = moralisNftContractAdressesFromJson(json.encode(req.body)).cursor;
      while (cursor != null) {
        var newReq = await _homeService.getNextNFTsContractAddresses("0x9aB328b9d8ece399e629Db772F73edFc8ddB244E", cursor);
        initialArray.addAll(moralisNftContractAdressesFromJson(json.encode(newReq.body)).result!);
        cursor = moralisNftContractAdressesFromJson(json.encode(newReq.body)).cursor;
      }
    }

     for (var element in initialArray) {
       if(!contractAddresses.contains(element.tokenAddress)) contractAddresses.add(element.tokenAddress!.toLowerCase());
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

  getNFTsTemporary(String wallet) async{
    nfts.value.clear();
    var req = await _homeService.getNextNFTByAlchemy(wallet, cursor.value);
    var res = nftAlchemyDtoFromJson(json.encode(req.body));
    res.pageKey == null || res.pageKey!.isEmpty ? cursor.value = "" : cursor.value = res.pageKey!;
    res.ownedNfts?.removeWhere((element) => element.title == null || element.title!.isEmpty || element.contractMetadata == null || element.contractMetadata!.openSea == null || element.contractMetadata!.openSea!.imageUrl == null || element.contractMetadata!.openSea!.imageUrl!.isEmpty || element.contractMetadata!.openSea!.collectionName == null ||  element.contractMetadata!.openSea!.collectionName!.isEmpty ||  element.contractMetadata!.openSea!.collectionName! == "Secret FLClub Pass");
    var gc = res.ownedNfts?.groupBy((el) => el.contract?.address);
    gc?.forEach((key, value) {
      nfts.add(CollectionDbDto(collectionName: value.first.contractMetadata!.openSea!.collectionName!, contractAddress: value.first.contract!.address!, collectionImage: value.first.contractMetadata!.openSea!.imageUrl!, collectionImages: value.map((e) => e.media!.first.thumbnail ?? e.media!.first.gateway!).toList()));
    });
    return nfts;
  }

  getNFTsTemporaryForOthers(String wallet) async{
    nfts.value.clear();
    var req = await _homeService.getNextNFTByAlchemy(wallet, cursorElse.value);
    var res = nftAlchemyDtoFromJson(json.encode(req.body));
    res.pageKey == null || res.pageKey!.isEmpty ? cursorElse.value = "" : cursorElse.value = res.pageKey!;
    res.ownedNfts?.removeWhere((element) => element.title == null || element.title!.isEmpty || element.contractMetadata == null || element.contractMetadata!.openSea == null || element.contractMetadata!.openSea!.imageUrl == null || element.contractMetadata!.openSea!.imageUrl!.isEmpty || element.contractMetadata!.openSea!.collectionName == null ||  element.contractMetadata!.openSea!.collectionName!.isEmpty ||  element.contractMetadata!.openSea!.collectionName! == "Secret FLClub Pass");
    var gc = res.ownedNfts?.groupBy((el) => el.contract?.address);
    gc?.forEach((key, value) {
      nfts.add(CollectionDbDto(collectionName: value.first.contractMetadata!.openSea!.collectionName!, contractAddress: value.first.contract!.address!, collectionImage: value.first.contractMetadata!.openSea!.imageUrl!, collectionImages: value.map((e) => e.media!.first.thumbnail ?? e.media!.first.gateway!).toList()));
    });
    return nfts;
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
      if(req.isOk) isConfiguring.value = false;
    } else if(req.isOk) {
      isConfiguring.value = false;
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
      }
    }
  }

  retrieveStories(int offset) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request;
    try{
      request = await _homeService.retrieveStories(accessToken, offset.toString());
    } on CastError{
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
          accessToken, wallet, nickname);
      if (request.statusCode == 401) {
        var requestToken = await _homeService.refreshToken(refreshToken);
        var refreshTokenDTO = refreshTokenDtoFromJson(
            json.encode(requestToken.body));
        accessToken = refreshTokenDTO.accessToken!;
        box.write(con.ACCESS_TOKEN, accessToken);
        await _homeService.updateNicknames(accessToken, wallet, nickname);
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
    } else if(request.isOk) nicknames.value = request.body!;
  }


}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
          (Map<K, List<E>> map, E element) =>
      map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}