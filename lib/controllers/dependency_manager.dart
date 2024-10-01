import 'package:get/get.dart';
import 'package:sirkl/controllers/auth/wallet_connect_modal_controller.dart';
import 'package:sirkl/controllers/call_controller.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/groups_controller.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:sirkl/controllers/inbox_controller.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/controllers/profile_controller.dart';

import 'web3_controller.dart';

class GlobalDependencyManager extends Bindings {
  final bool _permanent = true;

  @override
  void dependencies() {
    globalPut();
  }

  globalPut() {
    Get.put(NavigationController(), permanent: _permanent);
    Get.put(HomeController(), permanent: _permanent);
    Get.put(InboxController(), permanent: _permanent);
    Get.put(ProfileController(), permanent: _permanent);
    Get.put(GroupsController(), permanent: _permanent);
    Get.put(CallController(), permanent: _permanent);
    Get.put(CommonController(), permanent: _permanent);
    Get.put(Web3Controller(), permanent: _permanent);
    Get.put(WalletConnectModalController(), permanent: _permanent);
  }
}
