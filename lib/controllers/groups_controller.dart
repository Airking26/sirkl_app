import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/controllers/inbox_controller.dart';
import 'package:sirkl/models/admin_dto.dart';
import 'package:sirkl/models/group_creation_dto.dart';
import 'package:sirkl/models/group_dto.dart';
import 'package:sirkl/repositories/asset_repo.dart';
import 'package:sirkl/repositories/group_repo.dart';
import 'package:sirkl/repositories/user_repo.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

class GroupsController extends GetxController {
  final box = GetStorage();

  InboxController get _chatController => Get.find<InboxController>();
  var assetAvailableToCreateCommunity = <GroupCreationDto>[].obs;

  var queryCommunity = "".obs;
  var indexCommunity = 0.obs;
  var isAddingCommunity = false.obs;
  var isSearchActiveInCommunity = false.obs;
  var isLoadingAvailableAssets = true.obs;
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
  Future<void> retrieveAssetsAvailableToCreateCommunity() async {
    assetAvailableToCreateCommunity.value =
        await AssetRepo.retrieveAssetsAvailableToCommunityCreation();
    isLoadingAvailableAssets.value = false;
  }

  /// Function to retrieve the community owner in order to make him admin role
  Future<bool> isCommunityCreator(String wallet, String contract) async {
    return await AssetRepo.isCommunityCreator(wallet, contract);
  }

  /// Function to make a user admin or the opposite
  Future<void> changeAdminRole(AdminDto adminDTO) async =>
      await UserRepo.changeAdminRole(adminDTO);

  // TODO : Deprecate since mint will be made from server
  Future<void> addUserToSirklClub(String id) async =>
      await UserRepo.addUserToSirklClub(id);
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
