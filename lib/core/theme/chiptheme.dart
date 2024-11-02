import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

ChipThemeData chipTheme(double screenSize) {
  return ChipThemeData(
    backgroundColor: accentColor,
    elevation: 0,
    labelStyle: TextStyle(
      color: secondaryColor,
      fontSize: screenSize * 0.0185,
      fontWeight: FontWeight.bold,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
