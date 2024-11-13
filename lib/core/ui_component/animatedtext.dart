import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

TextScroll animatedText({required String text, required TextStyle style}) {
  return TextScroll(
    text,
    mode: TextScrollMode.endless,
    velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
    delayBefore: const Duration(seconds: 2),
    pauseBetween: const Duration(seconds: 3),
    style: style,
    textAlign: TextAlign.right,
    textDirection: TextDirection.ltr,
  );
}
