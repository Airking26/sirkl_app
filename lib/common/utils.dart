import 'package:flutter/material.dart';

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

}

extension StringX on String {
  isAz({caseSensitive = false}) {
    final target = caseSensitive ? this : toLowerCase();
    return target.codeUnitAt(0) > 96 && target.codeUnitAt(0) < 123;}
}