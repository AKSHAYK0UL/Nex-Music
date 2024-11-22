import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/appbartheme.dart';
import 'package:nex_music/core/theme/chiptheme.dart';
import 'package:nex_music/core/theme/dialogtheme.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/theme/listtiletheme.dart';
import 'package:nex_music/core/theme/navbartheme.dart';
import 'package:nex_music/core/theme/segmentedbutton_theme.dart';
import 'package:nex_music/core/theme/slidertheme.dart';
import 'package:nex_music/core/theme/snackbartheme.dart';
import 'package:nex_music/core/theme/texttheme.dart';

ThemeData themeData(BuildContext context) {
  final screenSize = MediaQuery.sizeOf(context).height;
  return ThemeData(
    canvasColor: backgroundColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: secondaryColor),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: appBarTheme(screenSize),
    textTheme: textTheme(context, screenSize),
    snackBarTheme: snackBarTheme(screenSize),
    listTileTheme: listTileTheme(context, screenSize),
    bottomNavigationBarTheme: bottomNavBarTheme(screenSize),
    chipTheme: chipTheme(screenSize),
    sliderTheme: sliderTheme(),
    segmentedButtonTheme: segmentedButtonTheme(context),
    dialogTheme: dialogTheme(screenSize),
  );
}
