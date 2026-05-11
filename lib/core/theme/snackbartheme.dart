import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/app_colors.dart';

SnackBarThemeData snackBarTheme(double screenSize, {bool isDark = false}) {
  return SnackBarThemeData(
    behavior: SnackBarBehavior.fixed,
    actionTextColor: AppColors.text(isDark),
    backgroundColor: AppColors.snackBar(isDark),
    contentTextStyle: TextStyle(
      color: AppColors.text(isDark),
      fontSize: screenSize * 0.0244,
      fontWeight: FontWeight.normal,
    ),
  );
}
