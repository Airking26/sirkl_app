import 'package:get/state_manager.dart';
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';

class NavigationController extends GetxController {
  var hideNavBar = false.obs;
  var controller = PersistentTabController(initialIndex: 0).obs;
}
