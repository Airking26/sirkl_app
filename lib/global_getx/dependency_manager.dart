import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sirkl/global_getx/home/home_controller.dart';
import 'package:sirkl/global_getx/profile/profile_controller.dart';
import 'package:sirkl/global_getx/wallet/s_wallet_connect.dart';

import '../config/s_config.dart';
import 'contracts/paid_group_contract.dart';

class GlobalDependencyManager extends Bindings {
  final bool _permanent = true;
  @override
  void dependencies() {
    // TODO: implement dependencies
    _globalPut();
  }

  _globalPut() {
    Get.put(PaidGroupContract(SConfig.paidGroupContract),
        permanent: _permanent);
    Get.put(SWalletConnectController(chainId: 5), permanent: _permanent);
    Get.put(HomeController(), permanent: _permanent);
    Get.put(ProfileController(), permanent: _permanent);
  }
}
