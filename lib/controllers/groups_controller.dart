import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/models/admin_dto.dart';
import 'package:sirkl/models/collection_dto.dart';
import 'package:sirkl/models/contract_address_dto.dart';
import 'package:sirkl/models/contract_creator_dto.dart';
import 'package:sirkl/models/group_creation_dto.dart';
import 'package:sirkl/models/group_dto.dart';
import 'package:sirkl/models/token_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/config/s_config.dart';
import 'package:sirkl/controllers/chats_controller.dart';
import 'package:sirkl/repo/group_repo.dart';
import 'package:sirkl/repo/home_repo.dart';

class GroupsController extends GetxController {
  final box = GetStorage();

  ChatsController get _chatController => Get.find<ChatsController>();
  var assetAvailableToCreateCommunity = <CollectionDbDto>[].obs;

  var queryCommunity = "".obs;
  var indexCommunity = 0.obs;
  var isAddingCommunity = false.obs;
  var isSearchActiveInCommunity = false.obs;
  var isLoadingAvailableAssets = true.obs;
  var refreshCommunity = false.obs;
  var retryProgress = false.obs;

  /// Function to create a community
  createCommunity(StreamChatClient streamChatClient,
      GroupCreationDto groupCreationDto) async {
    await GroupRepo.createGroup(groupCreationDto);
    await _createChannelCommunity(
        streamChatClient,
        GroupDto(
            name: groupCreationDto.name,
            image: groupCreationDto.picture,
            contractAddress: groupCreationDto.contractAddress),
        groupCreationDto.picture);
  }

  /// Private function to create a community channel
  Future<void> _createChannelCommunity(
      StreamChatClient streamChatClient, GroupDto groupDto, String pic) async {
    _chatController.channel.value = streamChatClient
        .channel("try", id: groupDto.contractAddress.toLowerCase(), extraData: {
      "members": ["bot_one", "bot_two", "bot_three"],
      "contractAddress": groupDto.contractAddress.toLowerCase(),
      "image": pic,
      "name": groupDto.name
    });
    await _chatController.channel.value!.watch();
    await _chatController.channel.value!
        .addMembers([streamChatClient.state.currentUser!.id]);
  }

  /// Function to retrieve assets owned by the user for which no community
  ///exist yet in order to choose from to create one
  retrieveAssetsAvailableToCreateCommunity(String wallet) async {
    List<GroupDto> groups = await GroupRepo.retrieveGroups();
    var tokens = await _retrieveTokenToCreateCommunity(wallet, groups);
    assetAvailableToCreateCommunity.value =
        tokens.toList().cast<CollectionDbDto>();
    isLoadingAvailableAssets.value = false;
  }

  /// Private function to retrieve token owned by the user for which no community
  ///exist yet in order to choose from to create one
  _retrieveTokenToCreateCommunity(String wallet, List<GroupDto> groups) async {
    var tokens = [];
    var tokenContractAddress =
        await HomeRepo.getTokenContractAddressesWithAlchemy(wallet: wallet);

    for (TokenBalance element in tokenContractAddress.result!.tokenBalances!) {
      if (element.tokenBalance != SConfig.emptyHexBalance &&
          !groups
              .map((e) => e.contractAddress.toLowerCase())
              .contains(element.contractAddress?.toLowerCase())) {
        var tokenDetails = await HomeRepo.getTokenMetadataWithAlchemy(
            token: element.contractAddress!);
        //if(tokenDetails.result != null && tokenDetails.result!.logo != null) {
        tokens.add(CollectionDbDto(
            collectionName: tokenDetails.result!.name!,
            contractAddress: element.contractAddress!,
            collectionImage: tokenDetails.result?.logo ?? SConfig.wIcon,
            collectionImages: [tokenDetails.result?.logo ?? SConfig.wIcon]));
        //}
      }
    }

    return await _retrieveNFTToCreateCommunity(wallet, tokens, groups);
  }

  /// Private function to retrieve nft owned by the user for which no community
  ///exist yet in order to choose from to create one
  _retrieveNFTToCreateCommunity(
      String wallet, List<dynamic> assets, List<GroupDto> groups) async {
    var cursor = "";
    var cursorInitialized = true;
    while (cursorInitialized || cursor.isNotEmpty) {
      ContractAddressDto contractAddress =
          await HomeRepo.getContractAddressesWithAlchemy(
              wallet: wallet, cursor: cursor);

      contractAddress.pageKey == null || contractAddress.pageKey!.isEmpty
          ? cursor = ""
          : cursor = "&pageKey=${contractAddress.pageKey}";
      contractAddress.contracts.removeWhere((element) =>
          groups
              .map((e) => e.contractAddress.toLowerCase())
              .contains(element.address?.toLowerCase()) ||
          element.title == null ||
          element.title!.isEmpty ||
          element.opensea == null ||
          element.opensea!.imageUrl == null ||
          element.opensea!.imageUrl!.isEmpty ||
          element.opensea!.collectionName == null ||
          element.opensea!.collectionName!.isEmpty);
      for (var element in contractAddress.contracts) {
        assets.add(CollectionDbDto(
            collectionName: element.opensea!.collectionName!,
            contractAddress: element.address!,
            collectionImage: element.opensea!.imageUrl!,
            collectionImages: element.media?.first.thumbnail == null
                ? [element.media!.first.gateway!]
                : [element.media!.first.thumbnail!]));
      }
      cursorInitialized = false;
    }

    return assets;
  }

  /// Function to retrieve the community owner in order to make him admin role
  Future<String?> retrieveCommunityOwner(String contract) async {
    ContractCreatorDto? contractCreator =
        await GroupRepo.retrieveCreatorGroup(contract);
    return contractCreator?.result?.first?.contractCreator;
  }

  /// Function to make a user admin or the opposite
  Future<void> changeAdminRole(AdminDto adminDTO) async =>
      await GroupRepo.changeAdminRole(adminDTO);

  // TODO : Deprecate since mint will be made from server
  Future<void> addUserToSirklClub(String id) async =>
      await GroupRepo.addUserToSirklClub(id);
}

/*retrieveGroupsToCreate(StreamChatClient streamChatClient) async {
    //List<GroupDto> groups = await GroupRepo.retrieveGroups();
    //groups = groups.sublist(2172);

    //for (var element in groups) {
    //if(!element.image.contains("token-image-placeholder.svg") && !element.image.contains("data:image")) {
    // await Future.delayed(const Duration(seconds: 1));
    try {
      /*var resp = await Dio().get(element.image,
                options: Options(responseType: ResponseType.bytes));
            final result = await ImageGallerySaver.saveImage(
                Uint8List.fromList(resp.data), quality: 100);
            var pic = await SimpleS3().uploadFile(
                File(result["filePath"].replaceAll("file://", "")),
                "sirkl-bucket",
                "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92",
                AWSRegions.euCentral1, debugLog: true);*/
      //await createChannel(streamChatClient, GroupDto(name: "SQR", image: "https://icodrops.com/wp-content/uploads/2022/07/A-WlK2Dl_400x400-150x150.jpg", contractAddress: "0x2B72867c32CF673F7b02d208B26889fEd353B1f8"), "https://icodrops.com/wp-content/uploads/2022/07/A-WlK2Dl_400x400-150x150.jpg");
      //await createChannel(streamChatClient, GroupDto(name: "SKALE SKL", image: "https://dynamic-assets.coinbase.com/3315e1fa2ce490fd33b1fb53f6c461cda0eb53a60c5ce9951858da803fc2f93840dc11abd573262aa033cf152c3294ed1d722334c895621e2ad500d323d211b4/asset_icons/4a2915c4374f0a2f50bd851396f368d2c442706abe07707906ca35d8bb403812.png", contractAddress: "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7"), "https://dynamic-assets.coinbase.com/3315e1fa2ce490fd33b1fb53f6c461cda0eb53a60c5ce9951858da803fc2f93840dc11abd573262aa033cf152c3294ed1d722334c895621e2ad500d323d211b4/asset_icons/4a2915c4374f0a2f50bd851396f368d2c442706abe07707906ca35d8bb403812.png");
    } on Exception catch (e) {
      print(e);
    }

    //}
    //}
  }*/
