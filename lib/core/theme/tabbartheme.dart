import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

TabBarThemeData get tabBarTheme {
  return TabBarThemeData(
    unselectedLabelColor: Colors.white38,
    labelColor: textColor,
    indicatorColor: accentColor,
    dividerColor: Colors.transparent,
    tabAlignment: TabAlignment.fill,
    overlayColor: const WidgetStatePropertyAll(
      Color.fromARGB(11, 255, 255, 255),
    ),
  );
}
