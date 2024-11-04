import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

AppBarTheme appBarTheme(double screenSize) {
  return AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      systemNavigationBarColor: backgroundColor,
      statusBarColor: Colors.transparent,
    ),
    titleTextStyle: TextStyle(
      color: textColor,
      fontSize: screenSize * 0.031,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(
      color: textColor,
    ),
    backgroundColor: backgroundColor,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleSpacing: 0,
  );
}
