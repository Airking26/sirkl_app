// ignore_for_file: use_build_context_synchronously, deprecated_member_use, prefer_typing_uninitialized_variables

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as htp;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/global_getx/web3/web3_controller.dart';
import 'package:sirkl/repo/chats_repo.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';
import 'package:sirkl/global_getx/common/common_controller.dart';
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
import 'package:sirkl/repo/home_repo.dart';
import 'package:sirkl/global_getx/navigation/navigation_controller.dart';
import 'package:sirkl/repo/profile_repo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:logger/logger.dart' as l;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../../common/model/update_fcm_dto.dart';
import '../../constants/save_pref_keys.dart';
import '../../repo/auth_repo.dart';

class HomeController extends GetxController {

  //RxList<DropdownMenuItem> dropDownMenuItems = <DropdownMenuItem>[].obs;

  NavigationController get _navigationController => Get.find<NavigationController>();
  CommonController get _commonController => Get.find<CommonController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  Web3Controller get _web3Controller => Get.find<Web3Controller>();

  final box = GetStorage();

  static SessionData? _sessionData;
  var sessionStatus;
  var _uri;
  var _connectResponse;

  Rx<List<List<StoryDto?>?>?> stories = (null as List<List<StoryDto?>?>?).obs;
  RxList<String> contractAddresses = <String>[].obs;
  Rx<PagingController<int, List<StoryDto?>?>> pagingController =
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
  var iHaveNft = false.obs;
  var heHasNft = false.obs;
  var isInFav = <String>[].obs;
  var isFavNftSelected = false.obs;
  var qrActive = false.obs;
  var notificationActive = true.obs;
  var streamChatToken = "".obs;
  late String chainToConnect;
  var isSigning = false.obs;
  var mint = false.obs;
  var isLoading = false.obs;

  Web3App? connector;

  retrieveAccessToken() {
    var accessTok = box.read(SharedPref.ACCESS_TOKEN);
    accessToken.value = accessTok ?? '';
    streamChatToken.value = box.read(SharedPref.STREAM_CHAT_TOKEN) ?? "";
    var checkBoxRead = box.read(con.contractAddresses);
    notificationActive.value = box.read(con.NOTIFICATION_ACTIVE) ?? true;
    if (checkBoxRead != null) {
      contractAddresses.value =
          box.read(con.contractAddresses).cast<String>() ?? [];
    } else {
      contractAddresses.value = [];
    }

    UserDTO user = box.read(SharedPref.USER) != null? UserDTO.fromJson(box.read(SharedPref.USER)) : UserDTO();
    
    userMe.value = user;
    id.value = user.id ?? '';
    userBlocked.value = box.read(con.USER_BLOCKED) ?? [];
  }

  switchActiveNotification(bool active) async {
    await box.write(con.NOTIFICATION_ACTIVE, active);
    notificationActive.value = active;
  }

  connectWallet(BuildContext context) async {

    connector ??= await Web3App.createInstance(
      logLevel: LogLevel.debug,
      projectId: 'bdfe4b74c44308ffb46fa4e6198605af',
      metadata: const PairingMetadata(
        name: 'SIRKL',
        description: 'SIRKL Login',
        url: 'https://sirkl.io/',
        icons: ["https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"],
      ),
    );

    ConnectResponse res = await connector!.connect(
        requiredNamespaces: {
      'eip155': const RequiredNamespace(
        events: ['session_request'],
        chains: ["eip155:1"],
        methods: [
          'personal_sign',
        ], // Requestable Methods
      ),
    });

    try {
      _connectResponse = res;
      var encode = Uri.encodeComponent('${res.uri}');
      var hasLaunched = await launchUrlString("metamask://wc?uri=$encode", mode: LaunchMode.externalApplication);
      if (hasLaunched == false) {
        isLoading.value = false;
        Fluttertoast.showToast(
            msg: "Not wallet was found, please create one in order to continue",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: SchedulerBinding
                        .instance.platformDispatcher.platformBrightness ==
                    Brightness.dark
                ? Colors.white
                : const Color(0xFF102437),
            textColor: SchedulerBinding
                        .instance.platformDispatcher.platformBrightness ==
                    Brightness.dark
                ? Colors.black
                : Colors.white,
            fontSize: 16.0);
      }
    } on Exception {
      isLoading.value = false;
      debugPrint("II");
      Fluttertoast.showToast(
          msg: "Not wallet was found, please create one in order to continue",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 10,
          backgroundColor:
              SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                      Brightness.dark
                  ? Colors.white
                  : const Color(0xFF102437),
          textColor:
              SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                      Brightness.dark
                  ? Colors.black
                  : Colors.white,
          fontSize: 16.0);
    }


    connector!.onSessionConnect.subscribe((args) {
      chainToConnect = args!.session.namespaces['eip155']!.accounts.first.split("eip155:")[1].split(':')[0];
      address.value = args.session.namespaces['eip155']!.accounts.first.split("eip155:$chainToConnect:")[1].toLowerCase();
      debugPrint('Session $address.value');
    });

    connector!.onSessionUpdate.subscribe((args) async{
      var t = args!.namespaces['eip155']!.accounts.last.split("eip155:")[1];
      if(t != "eip155:1"){
        await launchUrl(res.uri!, mode: LaunchMode.externalApplication);
      }
    });

  }

  String generateSessionMessage(String accountAddress) {
    String message =
        'Hello $accountAddress, welcome to our app. By signing this message you agree to learn and have fun with blockchain';

    return message;
  }

  signMessageWithMetamask(BuildContext context) async {
       try {
         _uri = _connectResponse.uri!;
         _sessionData = await _connectResponse.session.future;
         var message = generateSessionMessage(address.value);
         launchUrlString("metamask://wc?uri=$_uri", mode: LaunchMode.externalApplication);
         var signature = await connector?.request(topic: _sessionData!.topic, chainId: "eip155:${chainToConnect.toLowerCase()}", request: SessionRequestParams(method: 'personal_sign', params: [message, EthereumAddress.fromHex(address.value).hex]));
         await loginWithWallet(context, address.value, message, signature);
       } catch (exp) {
         isLoading.value = false;
         if (kDebugMode) {
           print(exp);
         }
     }
  }

  loginWithWallet(BuildContext context, String wallet, String message, String signature) async {
    SignInSuccessDto signSuccess = await AuthRepo.verifySignature( WalletConnectDto(
            wallet: wallet,
            message: message,
            signature: signature,
            platform: defaultTargetPlatform == TargetPlatform.android ? "android" : "iOS"));

      box.write(SharedPref.USER, signSuccess.user!.toJson());
      userMe.value = signSuccess.user!;
      
      accessToken.value = signSuccess.accessToken;
      debugPrint('Login with wallet ${signSuccess.user}');
      
      isConfiguring.value = true;
      isFirstConnexion.value = true;
      _navigationController.hideNavBar.value = false;
      var checkTime = DateTime.now().difference(userMe.value.createdAt!);
      if(checkTime.inSeconds < 60) {
        mint.value = true;
      }

      isLoading.value = false;
      await connectUser(StreamChat.of(context).client);
      putFCMToken(context, StreamChat.of(context).client, false);
      getAllNftConfig();
      retrieveInboxes();
  }

  putFCMToken(BuildContext context, StreamChatClient client, bool isLogged) async {
    if (accessToken.value.isNotEmpty) {
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      UserDTO userDTO = await HomeRepo.uploadFCMToken(UpdateFcmdto(token: fcmToken, platform: defaultTargetPlatform == TargetPlatform.android? 'android': 'iOS'));
        userMe.value = userDTO;
        box.write(
            SharedPref.USER, userDTO.toJson());
        await retrieveNicknames();
        await _commonController.showSirklUsers(id.value);
        await client.addDevice(fcmToken!, PushProvider.firebase,
            pushProviderName: "Firebase_Config");
        if (isLogged) updateAllNftConfig();
        if (Platform.isIOS) {
          var token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
          await HomeRepo.uploadAPNToken(token);
        }
        await getTokenContractAddress(client,
            userMe.value.wallet!
        );
    
    }
  }

  getTokenContractAddress(StreamChatClient? client, String wallet) async {
    var tokenContractAddress =
        await HomeRepo.getTokenContractAddressesWithAlchemy(wallet: wallet);
    var ethClient = Web3Client(
        'https://mainnet.infura.io/v3/c193b412278e451ea6725b674de75ef2',
        htp.Client());
    var balance = await ethClient
        .getBalance(EthereumAddress.fromHex(wallet.toLowerCase()));
    if (balance.getInWei > BigInt.zero &&
        !contractAddresses
            .contains("0x0000000000000000000000000000000000000000")) {
      contractAddresses.add("0x0000000000000000000000000000000000000000");
    }
     
      tokenContractAddress.result?.tokenBalances?.forEach((element) {
        if (element.tokenBalance !=
            "0x0000000000000000000000000000000000000000000000000000000000000000") {
          if (!contractAddresses.contains(element.contractAddress)) {
            contractAddresses.add(element.contractAddress!);
          }
        } else {
          contractAddresses.remove(element.contractAddress!);
        }
      });
      await getNFTsContractAddresses(client, wallet);
  }

  getDropDownList(String wallet) async {
    /*var request = await _homeService.getTokenContractAddressesWithAlchemy(wallet, "");
    //var ethClient = Web3Client('https://mainnet.infura.io/v3/c193b412278e451ea6725b674de75ef2', htp.Client());
    //var balance = await ethClient.getBalance(EthereumAddress.fromHex(wallet));
    //if(balance.getInWei > BigInt.zero) {
    dropDownMenuItems.add(DropdownMenuItem(
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
    )));
    //}
    if(request.isOk){
      var tokenContractAddress = tokenDtoFromJson(json.encode(request.body));
      tokenContractAddress.result?.tokenBalances?.forEach((element) async {
        if(element.tokenBalance != "0x0000000000000000000000000000000000000000000000000000000000000000"){
          var tokenMetadata = await getTokenMetadata(element.contractAddress!);
          dropDownMenuItems.add(DropdownMenuItem(
              child:
          Row(
            children: [
              tokenMetadata != null && tokenMetadata.result != null && tokenMetadata.result?.logo != null ? Image.network(tokenMetadata.result!.logo!, width: 22, height: 22,) : const SizedBox(),
              const SizedBox(width: 4,),
              tokenMetadata != null && tokenMetadata.result != null && tokenMetadata.result?.symbol != null ? Text(tokenMetadata.result!.symbol!, style: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500),) : const SizedBox()
            ],
          )));
        }
      });
    }*/
  }

  getNFTsContractAddresses(StreamChatClient? client, String wallet) async {
    ContractAddressDto contractAddress = await HomeRepo.getContractAddressesWithAlchemy(wallet: wallet, cursor: '');
      var initialArray = contractAddress.contracts;
      if (contractAddress.pageKey != null) {
        String? cursor = contractAddress.pageKey;
        while (cursor != null) {
          ContractAddressDto newContractAddress = await HomeRepo.getContractAddressesWithAlchemy(
             wallet: wallet, cursor:"&pageKey=$cursor");
          initialArray.addAll(newContractAddress.contracts);
          cursor = newContractAddress.pageKey;
        }
      }

      initialArray.removeWhere((element) =>
          element.title == null ||
          element.title!.isEmpty ||
          element.opensea == null ||
          element.opensea!.imageUrl == null ||
          element.opensea!.imageUrl!.isEmpty ||
          element.opensea!.collectionName == null ||
          element.opensea!.collectionName!.isEmpty ||
          element.tokenType == TokenType.UNKNOWN ||
          (element.tokenType == TokenType.ERC1155 &&
              element.opensea?.safelistRequestStatus ==
                  SafelistRequestStatus.NOT_REQUESTED));

      for (var element in initialArray) {
        if (!contractAddresses.contains(element.address?.toLowerCase())) {
          contractAddresses.add(element.address!.toLowerCase());
        }
      }

      box.write(con.contractAddresses, contractAddresses);
  }

  getAllNftConfig() async {
    await HomeRepo.getAllNFTConfig();
  }

  updateAllNftConfig() async {
   await HomeRepo.updateAllNFTConfig();
  }

  Future<List<NftDto>> getNFT(String id, bool isFav, int offset, UserDTO? user) async {
    if (offset == 0) isInFav.clear();
    List<NftDto> nfts = await HomeRepo.retrieveNFTs(id: id, isFav: isFav, offset: offset.toString());

        if (id == this.id.value) {
          if(userMe.value.hasSBT! && offset == 0) {
            nfts.add(NftDto(id: this.id.value, title: "SIRKL Club", collectionImage: "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png", images: ["https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"], contractAddress: "0x2B2535Ba07Cd144e143129DcE2dA4f21145a5011".toLowerCase(), isFav: false));
          }
          iHaveNft.value = true;
        } else {
          if(user != null && (user.hasSBT ?? false) && offset == 0){
            nfts.add(NftDto(id: id, title: "SIRKL Club", collectionImage: "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png", images: ["https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"], contractAddress: "0x2B2535Ba07Cd144e143129DcE2dA4f21145a5011".toLowerCase(), isFav: false));
          }
          heHasNft.value = true;
        }
  
      isInFav.addAll(nfts
          .where((element) => element.isFav!)
          .map((e) => e.contractAddress!)
          .toList());

      return nfts;
  }

  updateMe(UpdateMeDto updateMeDto) async {
    UserDTO userDto = await ProfileRepo.modifyUser(updateMeDto);
    box.write(SharedPref.USER, userDto.toJson());
    userMe.value = userDto;
  }

  updateStory(StoryModificationDto storyModificationDto) async {

    await HomeRepo.updateStory(storyModificationDto); 
      stories.value?[actualStoryIndex.value]
          ?.where((element) => element?.id == storyModificationDto.id)
          .first
          ?.readers = storyModificationDto.readers;
      stories.refresh();
    
  }

  Future<void> deleteStory(String createdBy, String id) async {

  await HomeRepo.deleteStory(createdBy: createdBy, id:id);
  }

  updateNickname(String wallet, String nickname) async {
    if (nicknames[wallet] != nickname) {
      nicknames[wallet] = nickname;
      nicknames.refresh();
      _commonController.users.refresh();

      await HomeRepo.updateNicknames(wallet: wallet,
      nickNameDto: 
        NicknameCreationDto(nickname: nickname));

    }
  }

  Future<void> getWelcomeMessage() async {
    await HomeRepo.receiveWelcomeMessage();
    
  }

  Future<void> connectUser(StreamChatClient client) async {
    retrieveAccessToken();
    if (accessToken.value.isNotEmpty) {
      if (client.wsConnectionStatus != ConnectionStatus.connected) {
        if (streamChatToken.value.isNullOrBlank! && (DateTime.now().difference(userMe.value.createdAt!) <
    const Duration(minutes: 1))) {
          String token =
              await ProfileRepo.retrieveTokenStreamChat();
          streamChatToken.value = token;
          await box.write(SharedPref.STREAM_CHAT_TOKEN, token);
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
              isInFollowing: userMe.value.isInFollowing);
        await client.connectUser(
                    User(
                        id: id.value,
                        name: userMe.value.userName.isNullOrBlank!
                            ? userMe.value.wallet
                            : userMe.value.userName!,
                        extraData: {"userDTO": userToPass}),
                    token);
                if (DateTime.now().difference(userMe.value.createdAt!) <
                    const Duration(minutes: 1)) {
                  await _commonController.addUserToSirkl(
                      "63f78a6188f7d4001f68699a", client, id.value);
                  await getWelcomeMessage();
                  await checkIfHasMessage(client);
                }
          isConfiguring.value = false;
          isFirstConnexion.value = false;
        } else {
          if(streamChatToken.value.isNullOrBlank!){
            String token =
            await ProfileRepo.retrieveTokenStreamChat();
            streamChatToken.value = token;
            await box.write(SharedPref.STREAM_CHAT_TOKEN, token);
          }
          await client.connectUser(User(id: id.value), streamChatToken.value);
          isConfiguring.value = false;
          isFirstConnexion.value = false;
          await checkIfHasMessage(client);
        }
      }
    }
  }

  retrieveNicknames() async {
    Map<dynamic, dynamic> names = await HomeRepo.retrieveNicknames();
      nicknames.value = names;
  }

  Future<List<List<StoryDto>>> retrieveStories(int offset) async {
    if (offset == 0) stories.value?.clear();

      List<List<StoryDto>> retrivedStories =
          await HomeRepo.retrieveStories(offset.toString());

      loadingStories.value = false;
      if (stories.value == null) {
        stories.value = retrivedStories;
      } else {
        stories.value =
            stories.value! + retrivedStories;
      }
      return retrivedStories;
  }

  retrieveInboxes() async {
      await ChatRepo.walletsToMessages();
  }

  registerNotification(NotificationRegisterDto notificationRegisterDto) async {
    await HomeRepo.registerNotification( notificationRegisterDto);
  }

  checkOfflineNotifAndRegister() async {
    var notifications = GetStorage().read(con.notificationSaved) ?? [];
    var notificationsToDelete = [];
    for (var notification in (notifications as List<dynamic>)) {
      await registerNotification(
          NotificationRegisterDto(message: notification));
      notificationsToDelete.add(notification);
    }
    var notificationsToSave = notifications
        .toSet()
        .difference(notificationsToDelete.toSet())
        .toList();
    await GetStorage().write(con.notificationSaved, notificationsToSave);
  }

  checkIfHasMessage(StreamChatClient client) async {
    client.queryChannels(filter: Filter.and([
      Filter.equal("type", "try"),
      Filter.or([
        Filter.in_("members", [id.value]),
        Filter.equal("created_by_id", id.value),
      ]),
      Filter.or([
        Filter.and([
          Filter.greater("last_message_at", "2022-11-23T12:00:18.54912Z"),
          Filter.exists("${id.value}_follow_channel"),
          Filter.equal("${id.value}_follow_channel", true),
          Filter.equal('isConv', true),
        ]),
        Filter.equal('isConv', false),
      ]),
    ]), channelStateSort: const [SortOption('last_message_at')], paginationParams: const PaginationParams(limit: 1)).listen((event) {
      if(event.first.state != null && event.first.state!.unreadCount > 0){
        _chatController.index.value = 0;
        _navigationController.controller.value.index = 3;
      } else {
        client.queryChannels(filter: Filter.and([
          Filter.equal("type", "try"),
          Filter.greater("last_message_at", "2022-11-23T12:00:18.54912Z"),
          Filter.equal('isConv', true),
          Filter.or([
            Filter.equal("created_by_id", id.value),
            Filter.in_("members", [id.value]),
          ]),
          Filter.or([
            Filter.notExists(
                "${id.value}_follow_channel"),
            Filter.equal(
                "${id.value}_follow_channel", false)
          ])
        ]), channelStateSort: const [SortOption('last_message_at')], paginationParams: const PaginationParams(limit: 1)).listen((event) {

          if(event.isNotEmpty && event.first.state != null && event.first.state!.unreadCount > 0) {
            _chatController.index.value = 1;
            _navigationController.controller.value.index = 3;
          }
        });
        }
    });
  }
}

isNumeric(string) => num.tryParse(string) != null;
