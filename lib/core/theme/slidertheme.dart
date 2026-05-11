import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/app_colors.dart';

SliderThemeData sliderTheme({bool isDark = false}) {
  return SliderThemeData(
    activeTrackColor: AppColors.sliderActive(isDark),
    thumbColor: AppColors.sliderActive(isDark),
    inactiveTrackColor: Colors.transparent,
  );
}
