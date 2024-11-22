import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

DialogTheme dialogTheme(double screenSize) {
  return DialogTheme(
    backgroundColor: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: Alignment.center,
    elevation: 1,
    titleTextStyle: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0264,
      fontWeight: FontWeight.w600,
    ),
    contentTextStyle: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0244,
      fontWeight: FontWeight.normal,
    ),
  );
}
