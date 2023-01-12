import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class NavigationController extends GetxController{

  var hideNavBar = false.obs;
  var controller = PersistentTabController().obs;


}