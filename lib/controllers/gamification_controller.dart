import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/common/enums/gamification_enums.dart';
import 'package:sirkl/common/save_pref_keys.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/models/task_progress_update_dto.dart';
import 'package:sirkl/models/user_progress_dto.dart';
import 'package:sirkl/repositories/gamification_repo.dart';

class GamificationController extends GetxController {
  HomeController get _homeController => Get.find<HomeController>();

  var hideGamificationNavBar = false.obs;
  var index = 0.obs;
  var indexLeaderboard = 0.obs;
  var dailyTasks = (null as UserProgressDto?).obs;
  var podium = (null as List<UserDTO>?).obs;
  var loadingTasks = false.obs;
  final box = GetStorage();

  Future<UserProgressDto> retrieveGamificationUserProgress(
      GamificationCycleType gamificationCycleType) async {
    loadingTasks.value = true;
    UserProgressDto userProgressDto =
        await GamificationRepo.retrieveUserGamificationProgress(
            gamificationCycleType);
    if (userProgressDto.user != null) {
      _homeController.userMe.value = userProgressDto.user!;
      box.write(SharedPref.USER, userProgressDto.user!.toJson());
    }
    dailyTasks.value = userProgressDto;
    loadingTasks.value = false;
    return userProgressDto;
  }

  Future<List<UserDTO>> retrieveLeaderboardDaily(int offset) async =>
      await GamificationRepo.retrieveLeaderboardDaily(offset.toString());

  Future<List<UserDTO>> retrieveLeaderboardWeekly(int offset) async =>
      await GamificationRepo.retrieveLeaderboardWeekly(offset.toString());

  Future<List<UserDTO>> retrieveLeaderboardAllTime(int offset) async =>
      await GamificationRepo.retrieveLeaderboardAllTime(offset.toString());

  Future<UserProgressDto> updateTaskProgress(
      TaskProgressUpdateDto taskProgressUpdateDTO) async {
    UserProgressDto userProgressDto =
        await GamificationRepo.updateTaskProgress(taskProgressUpdateDTO);
    if (userProgressDto.user != null) {
      _homeController.userMe.value = userProgressDto.user!;
      box.write(SharedPref.USER, userProgressDto.user!.toJson());
    }
    dailyTasks.value = userProgressDto;
    return userProgressDto;
  }
}
