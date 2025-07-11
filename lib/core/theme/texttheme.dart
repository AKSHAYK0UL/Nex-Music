import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

TextTheme textTheme(BuildContext context, double screenSize) {
  return TextTheme(
    titleLarge: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.031,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0264,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0211,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.030,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0244,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0192,
      fontWeight: FontWeight.normal,
    ),
    labelSmall: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0170,
      fontWeight: FontWeight.normal,
    ),
    labelMedium: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0220,
      fontWeight: FontWeight.w600,
    ),
    labelLarge: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0260,
      fontWeight: FontWeight.w500,
    ),
    displaySmall: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0180,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0230,
      fontWeight: FontWeight.w600,
    ),
    displayLarge: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0183,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0550,
      fontWeight: FontWeight.normal,
    ),
  );
}
