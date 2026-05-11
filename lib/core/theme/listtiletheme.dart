import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/app_colors.dart';

ListTileThemeData listTileTheme(double screenSize, {bool isDark = false}) {
  return ListTileThemeData(
    tileColor: AppColors.surface(isDark),
    iconColor: AppColors.text(isDark),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(screenSize * 0.01055),
    ),
    textColor: AppColors.text(isDark),
  );
}
