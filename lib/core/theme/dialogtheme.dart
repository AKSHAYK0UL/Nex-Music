import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/app_colors.dart';

DialogThemeData dialogTheme(double screenSize, {bool isDark = false}) {
  return DialogThemeData(
    backgroundColor: AppColors.surface(isDark),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    alignment: Alignment.center,
    elevation: 1,
    titleTextStyle: TextStyle(
      color: AppColors.text(isDark),
      fontSize: screenSize * 0.0264,
      fontWeight: FontWeight.w600,
    ),
    contentTextStyle: TextStyle(
      color: AppColors.text(isDark),
      fontSize: screenSize * 0.0244,
      fontWeight: FontWeight.normal,
    ),
  );
}
