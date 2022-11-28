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
import 'package:sirkl/common/model/group_dto.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/service/group_service.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/home/service/home_service.dart';

class GroupsController extends GetxController{

  var searchIsActive = false.obs;
  var query = "".obs;
  var addAGroup = false.obs;
  final _groupService = GroupService();
  final _homeService = HomeService();
  final box = GetStorage();
  var nftsAvailable = <CollectionDbDto>[].obs;
  final _chatController = Get.put(ChatsController());
  var isLoadingAvailableNFT = true.obs;

  createChannel(StreamChatClient streamChatClient, GroupDto groupDto, String pic) async{
    _chatController.channel.value = streamChatClient.channel("try", id: groupDto.contractAddress.toLowerCase(), extraData: {
      "members": ["bot_one_06e2b40d-5161-4d2f-88e4-09bd6cfac4db", "bot_two_b0b2f93b-92d4-40d7-9a99-c9765bbeca64", "bot_three_58b30baa-4198-4679-9fdf-ea888ecab388"],
      "contractAddress" : groupDto.contractAddress.toLowerCase(),
      "image": pic,
      "name": groupDto.name
    });
    await _chatController.channel.value!.watch();
    await _chatController.channel.value!.addMembers([streamChatClient.state.currentUser!.id]);
  }

  retrieveGroups(List<CollectionDbDto> nfts) async{
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
      nftsAvailable.value = nfts.where((element) => !groups.map((e) => e.contractAddress).contains(element.contractAddress)).toList();
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

      }
    } else if(req.isOk){
      var groups = groupDtoFromJson(json.encode(req.body)).sublist(1980);
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

}