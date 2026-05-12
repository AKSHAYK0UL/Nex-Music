import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nex_music/core/theme/app_colors.dart';
import 'package:nex_music/core/theme/appbartheme.dart';
import 'package:nex_music/core/theme/chiptheme.dart';
import 'package:nex_music/core/theme/dialogtheme.dart';
import 'package:nex_music/core/theme/elevatedbutton.dart';
import 'package:nex_music/core/theme/listtiletheme.dart';
import 'package:nex_music/core/theme/navbartheme.dart';
import 'package:nex_music/core/theme/segmentedbutton_theme.dart';
import 'package:nex_music/core/theme/slidertheme.dart';
import 'package:nex_music/core/theme/snackbartheme.dart';
import 'package:nex_music/core/theme/tabbartheme.dart';
import 'package:nex_music/core/theme/texttheme.dart';

ThemeData themeData(BuildContext context, {bool isDark = false}) {
  const double screenSize = 800.0;
  final bg = AppColors.background(isDark);
  final surface = AppColors.surface(isDark);

  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    canvasColor: bg,
    scaffoldBackgroundColor: bg,
    cardColor: AppColors.card(isDark),
    dividerColor: AppColors.divider(isDark),
    iconTheme: IconThemeData(color: AppColors.text(isDark)),
    colorScheme: ColorScheme.fromSwatch(
      brightness: isDark ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: surface,
      surface: surface,
      onSurface: AppColors.text(isDark),
      onBackground: AppColors.text(isDark),
    ),
    appBarTheme: appBarTheme(screenSize, isDark: isDark).copyWith(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: AppColors.navBar(isDark),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    ),
    textTheme: textTheme(screenSize, isDark: isDark),
    snackBarTheme: snackBarTheme(screenSize, isDark: isDark),
    listTileTheme: listTileTheme(screenSize, isDark: isDark),
    bottomNavigationBarTheme: bottomNavBarTheme(screenSize, isDark: isDark),
    chipTheme: chipTheme(screenSize, isDark: isDark),
    sliderTheme: sliderTheme(isDark: isDark),
    segmentedButtonTheme: segmentedButtonTheme(isDark: isDark),
    dialogTheme: dialogTheme(screenSize, isDark: isDark),
    tabBarTheme: tabBarTheme(isDark: isDark),
    elevatedButtonTheme: elevatedButtonTheme(isDark: isDark),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
