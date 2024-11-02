import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

AppBarTheme appBarTheme() {
  return AppBarTheme(
    iconTheme: IconThemeData(
      color: textColor,
    ),
    backgroundColor: backgroundColor,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleSpacing: 0,
  );
}
