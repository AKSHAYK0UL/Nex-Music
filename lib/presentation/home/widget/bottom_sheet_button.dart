import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';

Widget bottomSheetButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback? onPressed,
  required double screenSize,
  Color? color,
  Color? labelColor,
}) {
  return SizedBox(
    width: double.infinity,
    child: TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color ?? textColor,
        size: screenSize * 0.0360,
      ),
      style: ElevatedButton.styleFrom(
        alignment: Alignment.centerLeft,
        overlayColor: accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      label: animatedText(
        text: label,
        style: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(color: labelColor ?? textColor),
      ),
    ),
  );
}
