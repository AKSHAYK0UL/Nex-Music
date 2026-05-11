import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/app_colors.dart';

TabBarThemeData tabBarTheme({bool isDark = false}) {
  return TabBarThemeData(
    unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
    labelColor: AppColors.text(isDark),
    indicatorColor: AppColors.sliderActive(isDark),
    dividerColor: Colors.transparent,
    tabAlignment: TabAlignment.fill,
    overlayColor: const WidgetStatePropertyAll(
      Color.fromARGB(11, 255, 255, 255),
    ),
  );
}
