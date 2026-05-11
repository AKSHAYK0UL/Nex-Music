import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nex_music/core/theme/app_colors.dart';

AppBarTheme appBarTheme(double screenSize, {bool isDark = false}) {
  return AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.background(isDark),
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ),
    titleTextStyle: TextStyle(
      color: AppColors.text(isDark),
      fontSize: screenSize * 0.031,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: AppColors.text(isDark)),
    backgroundColor: AppColors.background(isDark),
    scrolledUnderElevation: 0,
    elevation: 0,
    titleSpacing: 0,
  );
}
