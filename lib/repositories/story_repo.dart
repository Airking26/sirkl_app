import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/models/story_creation_dto.dart';
import 'package:sirkl/models/story_dto.dart';
import 'package:sirkl/models/story_modification_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class StoryRepo {
  static Future<void> postStory(StoryCreationDto storyDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(url: SUrls.storyCreate, body: storyDto.toJson());
  }

  static Future<void> updateStory(StoryModificationDto modifiedStory) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.patch(url: SUrls.storyModify, body: modifiedStory.toJson());
  }

  static Future<List<List<StoryDto>>> retrieveStories(String offset) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.storyOthers(offset));
    return (res.jsonBody() as List)
        .map((list) => (list as List).map((e) => StoryDto.fromJson(e)).toList())
        .toList();
  }

  static Future<List<StoryDto>> retrieveMyStories() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.storyMine);

    return (res.jsonBody() as List<dynamic>)
        .map((e) => StoryDto.fromJson(e))
        .toList();
  }

  static Future<List<UserDTO>> retrieveReadersForAStory(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.storyReadersById(id));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => UserDTO.fromJson(e))
        .toList();
  }

  static Future<void> deleteStory(
      {required String createdBy, required String id}) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.delete(url: SUrls.deleteStory(createdBy, id));
  }
}
