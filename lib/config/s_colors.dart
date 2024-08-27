import 'package:flutter/material.dart';
import 'package:sirkl/common/enums/app_theme.dart';

class SColors {
  SColors._();
  static late Color activeColor;
  static void loadColors(AppThemeEnum appTheme) {
    if (appTheme == AppThemeEnum.light) {
      _loadLight();
    }
    _loadDark();
  }

  static void _loadLight() {
    activeColor = const Color(0xFF00CB7D);
  }

  static void _loadDark() {
    activeColor = const Color(0xFF00CB7D);
  }
}
