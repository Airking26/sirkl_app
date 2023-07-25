import 'package:flutter/material.dart';

import '../enums/app_theme.dart';



class SColors {
  SColors._();
  static late Color activeColor;
  static void loadColors(AppThemeEnum appTheme) {
    if (appTheme == AppThemeEnum.light) {
      _loadlight();
    }
    _loadDark();
  }

  static void _loadlight() {
    activeColor = const Color(0xFF00CB7D);
  }

  static void _loadDark() {
     activeColor = const Color(0xFF00CB7D);

  }


}
