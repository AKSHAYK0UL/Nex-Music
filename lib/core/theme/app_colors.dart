import 'package:flutter/material.dart';


class AppColors {
  AppColors._();

  //  Brand 
  static const Color primary = Color(0xFFFF2D55);

  //  Light 
  static const Color lightBackground   = Color(0xFFF2F2F7);
  static const Color lightSurface      = Color(0xFFFFFFFF);
  static const Color lightCard         = Color(0xFFFFFFFF);
  static const Color lightGroupBg      = Color(0xFFF2F2F7);
  static const Color lightText         = Color(0xFF000000);
  static const Color lightSubtext      = Color(0xFF6E6E72);
  static const Color lightDivider      = Color(0xFFD1D1D6);
  static const Color lightNavBar       = Color(0xFFFFFFFF);
  static const Color lightNavSelected  = Color(0xFFFF2D55);
  static const Color lightNavUnselected = Color(0xFF8E8E93);
  static const Color lightSnackBar     = Color(0xFF2F3855);
  static const Color lightSliderActive = Color(0xFF8EBBFF);

  //  Dark 
  static const Color darkBackground    = Color(0xFF000000);
  static const Color darkSurface       = Color(0xFF1C1C1E);
  static const Color darkCard          = Color(0xFF1C1C1E);
  static const Color darkGroupBg       = Color(0xFF1C1C1E);
  static const Color darkText          = Color(0xFFFFFFFF);
  static const Color darkSubtext       = Color(0xFF8E8E93);
  static const Color darkDivider       = Color(0xFF38383A);
  static const Color darkNavBar        = Color(0xFF1C1C1E);
  static const Color darkNavSelected   = Color(0xFFFF2D55);
  static const Color darkNavUnselected = Color(0xFF8E8E93);
  static const Color darkSnackBar      = Color(0xFF2C2C2E);
  static const Color darkSliderActive  = Color(0xFF8EBBFF);

  //  Helpers 
  static Color background(bool isDark)    => isDark ? darkBackground    : lightBackground;
  static Color surface(bool isDark)       => isDark ? darkSurface       : lightSurface;
  static Color card(bool isDark)          => isDark ? darkCard          : lightCard;
  static Color groupBg(bool isDark)       => isDark ? darkGroupBg       : lightGroupBg;
  static Color text(bool isDark)          => isDark ? darkText          : lightText;
  static Color subtext(bool isDark)       => isDark ? darkSubtext       : lightSubtext;
  static Color divider(bool isDark)       => isDark ? darkDivider       : lightDivider;
  static Color navBar(bool isDark)        => isDark ? darkNavBar        : lightNavBar;
  static Color navSelected(bool isDark)   => isDark ? darkNavSelected   : lightNavSelected;
  static Color navUnselected(bool isDark) => isDark ? darkNavUnselected : lightNavUnselected;
  static Color snackBar(bool isDark)      => isDark ? darkSnackBar      : lightSnackBar;
  static Color sliderActive(bool isDark)  => isDark ? darkSliderActive  : lightSliderActive;
}
