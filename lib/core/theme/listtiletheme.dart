import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

ListTileThemeData listTileTheme(BuildContext context, double screenSize) {
  return ListTileThemeData(
    tileColor: secondaryColor,
    iconColor: textColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(screenSize * 0.01055),
    ),
    textColor: textColor,
    titleTextStyle: Theme.of(context).textTheme.titleSmall,
    subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
  );
}
