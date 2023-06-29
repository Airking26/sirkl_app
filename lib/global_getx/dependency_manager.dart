import 'package:get/get.dart';
import 'package:sirkl/global_getx/calls/calls_controller.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';
import 'package:sirkl/global_getx/common/common_controller.dart';
import 'package:sirkl/global_getx/groups/groups_controller.dart';
import 'package:sirkl/global_getx/home/home_controller.dart';
import 'package:sirkl/global_getx/navigation/navigation_controller.dart';
import 'package:sirkl/global_getx/profile/profile_controller.dart';

class GlobalDependencyManager extends Bindings {

  final bool _permanent = true;

  @override
  void dependencies() {
    _globalPut();
  }

  _globalPut() {
    //Get.put(PaidGroupContract(SConfig.paidGroupContract), permanent: _permanent);
    //Get.put(SWalletConnectController(chainId: 5), permanent: _permanent);
    Get.put(NavigationController(), permanent: _permanent);
    Get.put(HomeController(), permanent: _permanent);
    Get.put(ChatsController(), permanent: _permanent);
    Get.put(ProfileController(), permanent: _permanent);
    Get.put(GroupsController(), permanent: _permanent);
    Get.put(CallsController(), permanent: _permanent);
    Get.put(CommonController(), permanent: _permanent);
  }
}
