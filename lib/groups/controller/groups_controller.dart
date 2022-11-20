import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:sirkl/common/model/group_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/service/group_service.dart';

class GroupsController extends GetxController{

  var searchIsActive = false.obs;
  var query = "".obs;
  final _groupService = GroupService();

  createChannel(StreamChatClient streamChatClient, GroupDto groupDto, String pic) async{
    await streamChatClient.channel("try", id: groupDto.contractAddress, extraData: {
      "members": [],
      "contractAdress" : groupDto.contractAddress,
      "image": pic,
      "name": groupDto.name
    }).watch();
  }

  retrieveGroups(StreamChatClient streamChatClient) async{
    var req = await _groupService.retrieveGroups();
    if(req.isOk){
      var groups = groupDtoFromJson(json.encode(req.body));
      for (var element in groups) {
        var downloadImage = await ImageDownloader.downloadImage(element.image);
        var pathImage = await ImageDownloader.findPath(downloadImage!);
        var pic = await SimpleS3().uploadFile(File(pathImage!), "sirkl-bucket", "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92", AWSRegions.euCentral1, debugLog: true);
        await createChannel(streamChatClient, element, pic);
      }
    }
  }

}