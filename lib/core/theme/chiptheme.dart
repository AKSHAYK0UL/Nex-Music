import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

ChipThemeData chipTheme(double screenSize) {
  return ChipThemeData(
    backgroundColor: secondaryColor,
    elevation: 0,
    labelStyle: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0190,
      fontWeight: FontWeight.bold,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(screenSize * 0.0263),
      side: BorderSide(color: secondaryColor, width: 0),
    ),
  );
}
