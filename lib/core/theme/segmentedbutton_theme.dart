import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

SegmentedButtonThemeData segmentedButtonTheme(BuildContext context) {
  return SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.grey.shade700;
          }
          return secondaryColor;
        },
      ),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
        (_) {
          return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.5));
        },
      ),
    ),
  );
}
