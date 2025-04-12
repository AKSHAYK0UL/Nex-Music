import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

TabBarTheme get tabBarTheme {
  return TabBarTheme(
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
