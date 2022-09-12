import 'package:flutter/material.dart';

class FloatingNavbarItem {
  final String? title;
  final String icon;
  final Widget? customWidget;

  FloatingNavbarItem({
    required this.icon,
    this.title,
    this.customWidget,
  });
}