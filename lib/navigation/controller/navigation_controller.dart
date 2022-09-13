import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';

class NavigationController extends GetxController{

  var currentPage = 0.obs;
  var pageController = PageController(initialPage: 0).obs;

  changeCurrentPage(int index){
    currentPage.value = index;
  }

}