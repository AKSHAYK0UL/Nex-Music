import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/app_colors.dart';

BottomNavigationBarThemeData bottomNavBarTheme(
    double screenSize, {bool isDark = false}) {
  return BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.navBar(isDark),
    elevation: 0,
    selectedIconTheme: IconThemeData(
      color: AppColors.navSelected(isDark),
      size: screenSize * 0.0320,
    ),
    selectedLabelStyle: TextStyle(
      color: AppColors.navSelected(isDark),
      fontSize: screenSize * 0.0195,
      fontWeight: FontWeight.normal,
    ),
    selectedItemColor: AppColors.navSelected(isDark),
    unselectedIconTheme: IconThemeData(
      color: AppColors.navUnselected(isDark),
      size: screenSize * 0.0320,
    ),
    unselectedLabelStyle: TextStyle(
      color: AppColors.navUnselected(isDark),
      fontSize: screenSize * 0.0195,
      fontWeight: FontWeight.normal,
    ),
    unselectedItemColor: AppColors.navUnselected(isDark),
  );
}
