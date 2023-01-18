import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/model/collection_dto.dart';
import 'package:sirkl/common/model/contract_creator_dto.dart';
import 'package:sirkl/common/model/group_dto.dart';
import 'package:sirkl/common/model/nft_alchemy_dto.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/service/group_service.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/home/service/home_service.dart';

class GroupsController extends GetxController{

  var searchIsActive = false.obs;
  var query = "".obs;
  var index = 0.obs;
  var addAGroup = false.obs;
  final _groupService = GroupService();
  final _homeService = HomeService();
  final box = GetStorage();
  var nftsAvailable = <CollectionDbDto>[].obs;
  final _chatController = Get.put(ChatsController());
  var isLoadingAvailableNFT = true.obs;

  createChannel(StreamChatClient streamChatClient, GroupDto groupDto, String pic) async{
    _chatController.channel.value = streamChatClient.channel("try", id: groupDto.contractAddress.toLowerCase(), extraData: {
      "members": ["bot_one", "bot_two", "bot_three"],
      "contractAddress" : groupDto.contractAddress.toLowerCase(),
      "image": pic,
      "name": groupDto.name
    });
    await _chatController.channel.value!.watch();
    await _chatController.channel.value!.addMembers([streamChatClient.state.currentUser!.id]);
  }

  getNFTsToCreateGroup(String wallet) async{
    var nfts = [];
    var cursor = "";
    var cursorInitialized = true;
    while(cursorInitialized || cursor.isNotEmpty){
      var req = await _homeService.getNextNFTByAlchemyForGroup(wallet, cursor);
      var res = nftAlchemyDtoFromJson(json.encode(req.body));
      res.pageKey == null || res.pageKey!.isEmpty ? cursor = "" : cursor = res.pageKey!;
      res.ownedNfts?.removeWhere((element) => element.title == null || element.title!.isEmpty || element.contractMetadata == null || element.contractMetadata!.openSea == null || element.contractMetadata!.openSea!.imageUrl == null || element.contractMetadata!.openSea!.imageUrl!.isEmpty  ||  element.contractMetadata!.openSea!.collectionName! == "Secret FLClub Pass");
      var gc = res.ownedNfts?.groupBy((el) => el.contract?.address);
      gc?.forEach((key, value) {
        nfts.add(CollectionDbDto(collectionName: value.first.title!, contractAddress: value.first.contract!.address!, collectionImage: value.first.contractMetadata!.openSea!.imageUrl!, collectionImages: value.map((e) => e.media!.first.thumbnail ?? e.media!.first.gateway!).toList()));
      });
      cursorInitialized = false;
    }

    return nfts;
  }

  Future<String?> retrieveCreatorGroup(String contract) async {
    var request = await _groupService.retrieveCreatorGroup(contract);
    if(request.isOk) {
      return contractCreatorDtoFromJson(json.encode(request.body))?.result?.first?.contractCreator;
    }
  }

  retrieveGroups(String wallet) async{
    var nfts = await getNFTsToCreateGroup(wallet);
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _groupService.retrieveGroups(accessToken);
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _groupService.retrieveGroups(accessToken);
      if(req.isOk){
        var groups = groupDtoFromJson(json.encode(req.body));
        nftsAvailable.value = nfts.where((element) => !groups.map((e) => e.contractAddress).contains(element.contractAddress)).toList();
        isLoadingAvailableNFT.value = false;
      }
    } else if(req.isOk){
      var groups = groupDtoFromJson(json.encode(req.body));
      nftsAvailable.value = nfts.where((element) => !groups.map((e) => e.contractAddress).contains(element.contractAddress)).toList().cast<CollectionDbDto>() ;
      isLoadingAvailableNFT.value = false;
    }
  }

  retrieveGroupsToCreate(StreamChatClient streamChatClient) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var req = await _groupService.retrieveGroups(accessToken);
    if(req.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      req = await _groupService.retrieveGroups(accessToken);
      if(req.isOk){
        var groups = groupDtoFromJson(json.encode(req.body)).sublist(1460);
        for (var element in groups) {
          if(!element.image.contains("token-image-placeholder.svg") && !element.image.contains("data:image")) {
            await Future.delayed(Duration(seconds: 1));
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
        }
      }
    } else if(req.isOk){
      var groups = groupDtoFromJson(json.encode(req.body)).sublist(1460);
      for (var element in groups) {
        if(!element.image.contains("token-image-placeholder.svg") && !element.image.contains("data:image")) {
          await Future.delayed(Duration(seconds: 1));
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
      }
    }
  }

  createGroup(StreamChatClient streamChatClient, String name, String image, String contractAddress)async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _groupService.createGroup(accessToken, name, image, contractAddress);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _groupService.createGroup(accessToken, name, image, contractAddress);
      if(request.isOk){
        await createChannel(streamChatClient, GroupDto(name: name, image: image, contractAddress: contractAddress), image);
      }
    } else if(request.isOk){
      await createChannel(streamChatClient, GroupDto(name: name, image: image, contractAddress: contractAddress), image);
    }
  }


  createHiro(StreamChatClient streamChatClient)async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _groupService.createGroup(accessToken, "SamuraiCats by Hiro Ando", "https://i.seadn.io/gae/1vG98EN2sNCzVMoSk8WVnLQy9BDCC8q1aQOZi2YkVK7IzO0ShN_wxX09b44b2sszfRAyPZqNHwF9TlBA7jE8ylUkvdESCDoi_32wyg?auto=format&w=384", "0xc8d2bf842b9f0b601043fb4fd5f23d22b9483911");
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _groupService.createGroup(accessToken, "SamuraiCats by Hiro Ando", "https://i.seadn.io/gae/1vG98EN2sNCzVMoSk8WVnLQy9BDCC8q1aQOZi2YkVK7IzO0ShN_wxX09b44b2sszfRAyPZqNHwF9TlBA7jE8ylUkvdESCDoi_32wyg?auto=format&w=384", "0xc8d2bf842b9f0b601043fb4fd5f23d22b9483911");
      if(request.isOk){
        await createChannel(streamChatClient, GroupDto(name: "SamuraiCats by Hiro Ando", image: "https://i.seadn.io/gae/1vG98EN2sNCzVMoSk8WVnLQy9BDCC8q1aQOZi2YkVK7IzO0ShN_wxX09b44b2sszfRAyPZqNHwF9TlBA7jE8ylUkvdESCDoi_32wyg?auto=format&w=384", contractAddress: "0xc8d2bf842b9f0b601043fb4fd5f23d22b9483911"), "https://i.seadn.io/gae/1vG98EN2sNCzVMoSk8WVnLQy9BDCC8q1aQOZi2YkVK7IzO0ShN_wxX09b44b2sszfRAyPZqNHwF9TlBA7jE8ylUkvdESCDoi_32wyg?auto=format&w=384");
      }
    } else if(request.isOk){
      await createChannel(streamChatClient, GroupDto(name: "SamuraiCats by Hiro Ando", image: "https://i.seadn.io/gae/1vG98EN2sNCzVMoSk8WVnLQy9BDCC8q1aQOZi2YkVK7IzO0ShN_wxX09b44b2sszfRAyPZqNHwF9TlBA7jE8ylUkvdESCDoi_32wyg?auto=format&w=384", contractAddress: "0xc8d2bf842b9f0b601043fb4fd5f23d22b9483911"), "https://i.seadn.io/gae/1vG98EN2sNCzVMoSk8WVnLQy9BDCC8q1aQOZi2YkVK7IzO0ShN_wxX09b44b2sszfRAyPZqNHwF9TlBA7jE8ylUkvdESCDoi_32wyg?auto=format&w=384");
    }
  }



}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
          (Map<K, List<E>> map, E element) =>
      map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}