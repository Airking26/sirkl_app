import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:sirkl/common/model/group_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/service/group_service.dart';

class GroupsController extends GetxController{

  var searchIsActive = false.obs;
  var query = "".obs;
  final _groupService = GroupService();

  createChannel(StreamChatClient streamChatClient, GroupDto groupDto, String pic) async{
    await streamChatClient.channel("try", id: groupDto.contractAddress.toLowerCase(), extraData: {
      "members": ["bot_one_06e2b40d-5161-4d2f-88e4-09bd6cfac4db", "bot_two_b0b2f93b-92d4-40d7-9a99-c9765bbeca64", "bot_three_58b30baa-4198-4679-9fdf-ea888ecab388"],
      "contractAddress" : groupDto.contractAddress.toLowerCase(),
      "image": pic,
      "name": groupDto.name
    }).watch();
  }

  retrieveGroups(StreamChatClient streamChatClient) async{
    var req = await _groupService.retrieveGroups();
    if(req.isOk){
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

  Future<void> addMember(Channel channel, String value) async{
    await channel.addMembers([value]);
  }

}