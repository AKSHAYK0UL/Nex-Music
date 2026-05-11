import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/app_colors.dart';

SegmentedButtonThemeData segmentedButtonTheme({bool isDark = false}) {
  return SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? Colors.grey.shade600 : Colors.grey.shade700;
          }
          return AppColors.surface(isDark);
        },
      ),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
        (_) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.5)),
      ),
    ),
  );
}
