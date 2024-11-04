import 'package:flutter/material.dart';
import 'package:overflow_text_animated/overflow_text_animated.dart';

OverflowTextAnimated animatedText(
    {required String text, required TextStyle style}) {
  return OverflowTextAnimated(
    text: text,
    style: style,
    animation: OverFlowTextAnimations.scrollOpposite,
    animateDuration: const Duration(milliseconds: 3000),
  );
}
