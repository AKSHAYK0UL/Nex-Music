import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/app_colors.dart';

ChipThemeData chipTheme(double screenSize, {bool isDark = false}) {
  return ChipThemeData(
    backgroundColor: AppColors.surface(isDark),
    elevation: 0,
    labelStyle: TextStyle(
      color: AppColors.text(isDark),
      fontSize: screenSize * 0.0190,
      fontWeight: FontWeight.bold,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(screenSize * 0.0263),
      side: BorderSide(color: AppColors.surface(isDark), width: 0),
    ),
  );
}
