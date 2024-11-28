import 'package:sirkl/common/enums/gamification_enums.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/models/task_progress_update_dto.dart';
import 'package:sirkl/models/user_progress_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class GamificationRepo {
  static Future<UserProgressDto> retrieveUserGamificationProgress(
      GamificationCycleType gamificationCycleType) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(
        SUrls.retrieveUserGamificationProgress(gamificationCycleType.name));
    return UserProgressDto.fromJson(res.jsonBody());
  }

  static Future<List<UserDTO>> retrieveLeaderboardDaily(String offset) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.retrieveLeaderboardDaily(offset));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => UserDTO.fromJson(e))
        .toList();
  }

  static Future<List<UserDTO>> retrieveLeaderboardWeekly(String offset) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.retrieveLeaderboardWeekly(offset));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => UserDTO.fromJson(e))
        .toList();
  }

  static Future<List<UserDTO>> retrieveLeaderboardAllTime(String offset) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.retrieveLeaderboardAllTime(offset));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => UserDTO.fromJson(e))
        .toList();
  }

  static Future<UserProgressDto> updateTaskProgress(
      TaskProgressUpdateDto taskProgressUpdateDTO) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.post(
        url: SUrls.updateGamification, body: taskProgressUpdateDTO.toJson());
    return UserProgressDto.fromJson(res.jsonBody());
  }
}
