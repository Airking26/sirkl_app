import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/common/constants.dart' as con;

class Utils{

  YYDialog dialogPopMenu(BuildContext context) {
    return YYDialog().build(context)
      ..width = 120
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = Colors.transparent
      ..margin = EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.editProfileRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? Color(0xff9BA0A5) : Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.contactUsRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? Color(0xff9BA0A5) : Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.logoutRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? Color(0xff9BA0A5) : Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

}