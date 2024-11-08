import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

SliderThemeData sliderTheme() {
  return SliderThemeData(
    activeTrackColor: accentColor,
    thumbColor: accentColor,
    inactiveTrackColor: Colors.transparent,
  );
}
