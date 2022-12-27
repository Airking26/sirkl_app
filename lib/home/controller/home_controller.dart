import 'dart:convert';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/chats/service/chats_service.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/collection_dto.dart';
import 'package:sirkl/common/model/moralis_metadata_dto.dart';
import 'package:sirkl/common/model/moralis_nft_contract_addresse.dart';
import 'package:sirkl/common/model/moralis_root_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/story_dto.dart';
import 'package:sirkl/common/model/story_modification_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/model/wallet_connect_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/service/home_service.dart';
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

  final _callController = Get.put(CallsController());
  final _commonController = Get.put(CommonController());

  Rx<AgoraRtmClient?> agoraClient = (null as AgoraRtmClient?).obs;
  Rx<List<List<StoryDto?>?>?> stories = (null as List<List<StoryDto?>?>?).obs;
  final box = GetStorage();

  var id = "".obs;
  var indexBarHeight = 400.0.obs;
  var isConfiguring = false.obs;
  var tokenAgoraRTM = "".obs;
  var tokenAgoraRTC = "".obs;
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

  var sessionStatus;
  var _uri;

  final connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
      name: 'SIRKL',
      description: 'SIRKL Login',
      url: 'https://walletconnect.org',
      icons: [
        'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
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
      var signSuccess = signInSuccessDtoFromJson(json.encode(request.body));
      userMe.value = signSuccess.user!;
      box.write(con.ACCESS_TOKEN, signSuccess.accessToken!);
      accessToken.value = signSuccess.accessToken!;
      box.write(con.REFRESH_TOKEN, signSuccess.refreshToken!);
      box.write(con.USER, userToJson(signSuccess.user!));
      isConfiguring.value = true;
      await putFCMToken(context, StreamChat.of(context).client);
      await retrieveInboxes();
    }
  }

  putFCMToken(BuildContext context, StreamChatClient client) async {
    await retrieveAccessToken();
    if(accessToken.value.isNotEmpty) {
      final firebaseMessaging = await FirebaseMessaging.instance.getToken();
      var accessToken = box.read(con.ACCESS_TOKEN); //?? this.accessToken.value;
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
          retrieveAccessToken();
          _commonController.showSirklUsers(id.value);
          await retrieveTokenStreamChat(client, firebaseMessaging!);
          await retrieveTokenAgoraRTM(id.value);
          await getNFTsContractAddresses(client);
        }
      } else if(request.isOk){
        userMe.value = userFromJson(json.encode(request.body));
        retrieveAccessToken();
        _commonController.showSirklUsers(id.value);
        await retrieveTokenStreamChat(client, firebaseMessaging!);
        await retrieveTokenAgoraRTM(id.value);
        await getNFTsContractAddresses(client);
      } else {
        debugPrint(request.statusText);
        debugPrint(request.bodyString);
      }
    }
  }

  retrieveAccessToken(){
    var accessTok = box.read(con.ACCESS_TOKEN);
    accessToken.value = accessTok ?? '';
    var d = box.read(con.USER);
    id.value = d != null ? userFromJson(box.read(con.USER) ?? "").id ?? "": "";
  }

  getNFTsContractAddresses(StreamChatClient? client) async{
    var req = await _homeService.getNFTsContractAddresses("0xC6A4434619fCe9266bD7e3d0A9117D2C9b49Fd87");
    if(req.body != null){
    var initialArray = moralisNftContractAdressesFromJson(json.encode(req.body)).result!;
    if(moralisNftContractAdressesFromJson(json.encode(req.body)).cursor != null) {
      var cursor = moralisNftContractAdressesFromJson(json.encode(req.body))
          .cursor;
      while (cursor != null) {
        var newReq = await _homeService.getNextNFTsContractAddresses(
            "0xC6A4434619fCe9266bD7e3d0A9117D2C9b49Fd87", cursor);
        initialArray.addAll(
            moralisNftContractAdressesFromJson(json.encode(newReq.body))
                .result!);
        cursor =
            moralisNftContractAdressesFromJson(json.encode(newReq.body)).cursor;
      }
    }

      List<String> contractAddresses = [];
      for (var element in initialArray) {contractAddresses.add(element.tokenAddress!);}

      var addressesAbsent = userMe.value.contractAddresses!.toSet().difference(contractAddresses.toSet()).toList();
      if(client != null && addressesAbsent.isNotEmpty) {
        for (var absentAddress in addressesAbsent) {
          //await client.removeChannelMembers(absentAddress.toLowerCase(), "try", [id.value]);
        }
      }
      await updateMe(UpdateMeDto(contractAddresses: contractAddresses));
    }

  }

  getNFTsTemporary(String wallet, BuildContext context) async{
    isLoadingNfts.value = true;
    nfts.value.clear();
    var req = await _homeService.getNFTs("0xC6A4434619fCe9266bD7e3d0A9117D2C9b49Fd87");
    var mainCollection = moralisRootDtoFromJson(json.encode(req.body)).result!;
    var cursor = moralisRootDtoFromJson(json.encode(req.body)).cursor;
    while(cursor != null){
      var newReq = await _homeService.getNextNFTs("0xC6A4434619fCe9266bD7e3d0A9117D2C9b49Fd87", cursor);
      mainCollection.addAll(moralisRootDtoFromJson(json.encode(newReq.body)).result!);
      cursor = moralisRootDtoFromJson(json.encode(newReq.body)).cursor;
    }

    mainCollection.removeWhere((element) => element?.metadata == null || element?.name == null || moralisMetadataDtoFromJson(element!.metadata!).image == null || element.metadata != null && moralisMetadataDtoFromJson(element!.metadata!).image != null && moralisMetadataDtoFromJson(element.metadata!).image!.contains(".mp4"));
    var groupedCollection = mainCollection.groupBy((p0) => p0!.tokenAddress);

    groupedCollection.forEach((key, value) {
      nfts.add(CollectionDbDto(collectionName: value.first!.name!, contractAddress: value.first!.tokenAddress!, collectionImages: value.map((e) {
        String image;
          if(e!.metadata != null )debugPrint("${value.first!.name!} : ${moralisMetadataDtoFromJson(e.metadata!).image!}");
          if (moralisMetadataDtoFromJson(e.metadata!).image!.startsWith("ipfs://")) {
            image = "https://ipfs.moralis.io:2053/ipfs/${moralisMetadataDtoFromJson(e.metadata!).image!.split("ipfs://").last}";
          }
          else if (moralisMetadataDtoFromJson(e.metadata!).image!.contains("/ipfs/")) {
            image =  "https://ipfs.moralis.io:2053/ipfs/${moralisMetadataDtoFromJson(e.metadata!).image!.split("/ipfs/").last}";
          }
          else {
            image = moralisMetadataDtoFromJson(e.metadata!).image!;
          }
          return image;
      }
      ).toList()));
    });
    nfts.refresh();
    isLoadingNfts.value = false;
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
    var accessToken = box.read(con.ACCESS_TOKEN);// ?? this.accessToken.value;
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
      var userToPass = userMe.value;
      userToPass.contractAddresses = [];
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
              extraData: {"userDTO": userToPass}), request.body!);
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

  retrieveTokenAgoraRTC(String channel, String role, String tokenType, String id) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.retrieveTokenAgoraRTC(accessToken, channel, role, tokenType, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.retrieveTokenAgoraRTC(accessToken, channel, role, tokenType, id);
      if(request.isOk) tokenAgoraRTC.value = request.body!;
    } else if(request.isOk) {
      tokenAgoraRTC.value = request.body!;
    }
  }

  retrieveTokenAgoraRTM(String id) async{
    agoraClient.value = await _callController.initClient();
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.retrieveTokenAgoraRTM(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.retrieveTokenAgoraRTM(accessToken, id);
      if(request.isOk) {
        tokenAgoraRTM.value = request.bodyString!;
        await agoraClient.value?.login(tokenAgoraRTM.value, id);
        await _callController.createClient(agoraClient.value!);
      }
    } else if(request.isOk) {
      tokenAgoraRTM.value = request.bodyString!;
      await agoraClient.value?.login(tokenAgoraRTM.value, id);
      await _callController.createClient(agoraClient.value!);
    }
  }

  checkIfUserExists(String wallet) async{
    var request = await _homeService.isUserExists(wallet);
    return request.body! == "false" ? true : false;
  }

  retrieveStories(int offset) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _homeService.retrieveStories(accessToken, offset.toString());
    if(request.statusCode == 401) {
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request =  await _homeService.retrieveStories(accessToken, offset.toString());
      if(request.isOk) {
        if(stories.value == null) {
          stories.value = storyDtoFromJson(json.encode(request.body));
        } else {
          stories.value = stories.value! + storyDtoFromJson(json.encode(request.body));
        }        return storyDtoFromJson(json.encode(request.body));
      }
    } else if(request.isOk) {
      if(stories.value == null) {
        stories.value = storyDtoFromJson(json.encode(request.body));
      } else {
        stories.value = stories.value! + storyDtoFromJson(json.encode(request.body));
      }
      return storyDtoFromJson(json.encode(request.body));
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
      if(request.isOk) {};
    } else if(request.isOk) {
    }
  }


}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
          (Map<K, List<E>> map, E element) =>
      map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}