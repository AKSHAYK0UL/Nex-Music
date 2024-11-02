import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

SnackBarThemeData snackBarTheme(double screenSize) {
  return SnackBarThemeData(
    behavior: SnackBarBehavior.fixed,
    actionTextColor: textColor,
    backgroundColor: secondaryColor,
    contentTextStyle: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0244,
      fontWeight: FontWeight.normal,
    ),
  );
}
