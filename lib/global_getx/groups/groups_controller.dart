import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:sirkl/common/constants.dart';
import 'package:sirkl/common/model/token_dto.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';
import 'package:sirkl/common/model/admin_dto.dart';
import 'package:sirkl/common/model/collection_dto.dart';
import 'package:sirkl/common/model/contract_address_dto.dart';
import 'package:sirkl/common/model/contract_creator_dto.dart';
import 'package:sirkl/common/model/group_creation_dto.dart';
import 'package:sirkl/common/model/group_dto.dart';
import 'package:sirkl/common/model/nft_alchemy_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/global_getx/home/home_controller.dart';
import 'package:sirkl/repo/group_repo.dart';
import 'package:sirkl/repo/home_repo.dart';
import 'package:web3dart/web3dart.dart';

class GroupsController extends GetxController{

  final box = GetStorage();

  ChatsController get _chatController => Get.find<ChatsController>();
  var nftAvailable = <CollectionDbDto>[].obs;

  var query = "".obs;
  var index = 0.obs;
  var addAGroup = false.obs;
  var searchIsActive = false.obs;
  var isLoadingAvailableNFT = true.obs;
  var refreshGroups = false.obs;
  var retryProgress = false.obs;

  createChannel(StreamChatClient streamChatClient, GroupDto groupDto, String pic) async{
    _chatController.channel.value = streamChatClient.channel("try",
        id: groupDto.contractAddress.toLowerCase(),
        extraData: {
      "members": ["bot_one", "bot_two", "bot_three"],
      "contractAddress" : groupDto.contractAddress.toLowerCase(),
      "image": pic,
      "name": groupDto.name
    });
    await _chatController.channel.value!.watch();
    await _chatController.channel.value!.addMembers([streamChatClient.state.currentUser!.id]);
  }

  getNFTsToCreateGroup(String wallet, List<dynamic> nfts, List<GroupDto> groups) async {
    var cursor = "";
    var cursorInitialized = true;
    while(cursorInitialized || cursor.isNotEmpty){
      ContractAddressDto contractAddress = await HomeRepo.getContractAddressesWithAlchemy(wallet: wallet, cursor: cursor );
    
      contractAddress.pageKey == null || contractAddress.pageKey!.isEmpty ? cursor = "" : cursor = "&pageKey=${contractAddress.pageKey}";
      contractAddress.contracts.removeWhere((element) => groups.map((e) => e.contractAddress.toLowerCase()).contains(element.address?.toLowerCase()) || element.title == null || element.title!.isEmpty || element.opensea == null || element.opensea!.imageUrl == null || element.opensea!.imageUrl!.isEmpty  ||  element.opensea!.collectionName == null || element.opensea!.collectionName!.isEmpty);
      for (var element in contractAddress.contracts) {
        nfts.add(CollectionDbDto(collectionName: element.opensea!.collectionName!, contractAddress: element.address!, collectionImage: element.opensea!.imageUrl!, collectionImages: element.media?.first.thumbnail == null ? [element.media!.first.gateway!] : [element.media!.first.thumbnail!]));
      }
      cursorInitialized = false;
    }

    return nfts;
  }

  getTokenToCreateGroup(String wallet, List<GroupDto> groups) async {
    var tokens = [];
    var tokenContractAddress =
    await HomeRepo.getTokenContractAddressesWithAlchemy(wallet: wallet);

    for(TokenBalance element in tokenContractAddress.result!.tokenBalances!) {
      if (element.tokenBalance != "0x0000000000000000000000000000000000000000000000000000000000000000" && !groups.map((e) => e.contractAddress.toLowerCase()).contains(element.contractAddress?.toLowerCase())) {
        var tokenDetails = await HomeRepo.getTokenMetadataWithAlchemy(token: element.contractAddress!);
        //if(tokenDetails.result != null && tokenDetails.result!.logo != null) {
          tokens.add(CollectionDbDto(collectionName: tokenDetails.result!.name!,
              contractAddress: element.contractAddress!,
              collectionImage: tokenDetails.result?.logo ?? "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png",
              collectionImages: [tokenDetails.result?.logo ?? "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"]));
        //}
      }
    }

    return await getNFTsToCreateGroup(wallet, tokens, groups);
  }

  retrieveNFTAvailableForCreation(String wallet) async{
    List<GroupDto> groups = await GroupRepo.retrieveGroups();
    var tokens = await getTokenToCreateGroup(wallet, groups);
    nftAvailable.value = tokens.toList().cast<CollectionDbDto>();
    isLoadingAvailableNFT.value = false;
  }

  Future<String?> retrieveCreatorGroup(String contract) async {
    ContractCreatorDto? contractCreator = await GroupRepo.retrieveCreatorGroup(contract);
    return contractCreator?.result?.first?.contractCreator;
  }

  retrieveGroupsToCreate(StreamChatClient streamChatClient) async{
    List<GroupDto> groups = await GroupRepo.retrieveGroups();
    //groups = groups.sublist(2172);
  
      for (var element in groups) {
        if(!element.image.contains("token-image-placeholder.svg") && !element.image.contains("data:image")) {
          await Future.delayed(const Duration(seconds: 1));
          try{
            var resp = await Dio().get(element.image,
                options: Options(responseType: ResponseType.bytes));
            final result = await ImageGallerySaver.saveImage(
                Uint8List.fromList(resp.data), quality: 100);
            var pic = await SimpleS3().uploadFile(
                File(result["filePath"].replaceAll("file://", "")),
                "sirkl-bucket",
                "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92",
                AWSRegions.euCentral1, debugLog: true);
            await createChannel(streamChatClient, element, pic);
          }
          on Exception catch (e){
            print(e);
          }

        }
      }
  }

  createGroup(StreamChatClient streamChatClient, GroupCreationDto groupCreationDto)async{

    await GroupRepo.createGroup(groupCreationDto);
    await createChannel(streamChatClient, GroupDto(name: groupCreationDto.name, image: groupCreationDto.picture, contractAddress: groupCreationDto.contractAddress), groupCreationDto.picture);
  }

  Future<void> changeAdminRole(AdminDto adminDTO) async{

    await GroupRepo.changeAdminRole(adminDTO);

  }


}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
          (Map<K, List<E>> map, E element) =>
      map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}