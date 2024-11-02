import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

BottomNavigationBarThemeData bottomNavBarTheme(double screenSize) {
  return BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: backgroundColor,
    elevation: 0,
    selectedIconTheme: IconThemeData(
      color: accentColor,
      size: screenSize * 0.0329,
    ),
    selectedLabelStyle: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.0211,
      fontWeight: FontWeight.w600,
    ),
    selectedItemColor: textColor,
    unselectedIconTheme: IconThemeData(
      color: Colors.grey.shade600,
      size: screenSize * 0.0303,
    ),
    unselectedLabelStyle: TextStyle(
      color: Colors.grey.shade600,
      fontSize: screenSize * 0.0211,
      fontWeight: FontWeight.normal,
    ),
    unselectedItemColor: Colors.grey.shade600,
  );
}
