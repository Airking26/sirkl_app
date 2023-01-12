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
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.editProfileRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.contactUsRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.logoutRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

  void showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF102437),
        content: Text(message, textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "Gilroy", fontSize: 15, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) : Colors.white),),
        //action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

}

extension StringX on String {
  isAz({caseSensitive = false}) {
    final target = caseSensitive ? this : toLowerCase();
    return target.codeUnitAt(0) > 96 && target.codeUnitAt(0) < 123;}
}