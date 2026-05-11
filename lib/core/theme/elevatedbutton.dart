import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/app_colors.dart';

ElevatedButtonThemeData elevatedButtonTheme({bool isDark = false}) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.background(isDark),
      iconColor: AppColors.sliderActive(isDark),
    ),
  );
}
