import 'package:flutter/material.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:sirkl/common/language.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/controllers/home_controller.dart';

class Utils{

  void showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.removeCurrentSnackBar();
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF102437),
        content: Text(message, textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "Gilroy", fontSize: 15, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) : Colors.white),),
        //action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  String displayName(UserDTO user, HomeController controller){
    if(controller.nicknames[user.wallet] != null){
      if(user.userName == null || user.userName!.isEmpty){
        return controller.nicknames[user.wallet] + "(" + user.userName + ")";
      } else {
        return controller.nicknames[user.wallet] + "(" + user.wallet!.substring(0,6) + "..." + user.wallet!.substring(user.wallet!.length - 4) + ")";
      }
    } else {
      if(user.userName == null || user.userName!.isEmpty){
        return "${user.wallet!.substring(0,6)}...${user.wallet!.substring(user.wallet!.length - 4)}";
      } else {
        return user.userName!;
      }
    }
  }

}

String displayName(UserDTO user, HomeController controller){
  if(controller.nicknames[user.wallet] != null && controller.nicknames[user.wallet]!.isNotEmpty){
    if(user.userName != null && user.userName!.isNotEmpty){
      return controller.nicknames[user.wallet] + " (" + user.userName + ")";
    } else {
      return controller.nicknames[user.wallet] + " (" + user.wallet!.substring(0,6) + "..." + user.wallet!.substring(user.wallet!.length - 4) + ")";
    }
  } else {
    if(user.userName == null || user.userName!.isEmpty){
      return "${user.wallet!.substring(0,6)}...${user.wallet!.substring(user.wallet!.length - 4)}";
    } else {
      return user.userName!;
    }
  }
}