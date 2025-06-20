import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

ElevatedButtonThemeData elevatedButtonTheme() {
  return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    iconColor: accentColor,
  ));
}
