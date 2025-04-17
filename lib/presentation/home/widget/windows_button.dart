import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowsButton extends StatelessWidget {
  const WindowsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(
          colors: minButtonColors,
        ),
        MaximizeWindowButton(
          colors: maxButtonColors,
        ),
        CloseWindowButton(
          colors: closeButtonColors,
        ),
      ],
    );
  }
}

final maxButtonColors = WindowButtonColors(
  iconNormal: const Color(0xFF805306),
  mouseOver: const Color(0xFFF6A00C),
  mouseDown: const Color(0xFF805306),
  iconMouseOver: const Color(0xFF805306),
  iconMouseDown: const Color(0xFFFFD500),
);

final closeButtonColors = WindowButtonColors(
  mouseOver: Colors.white,
  mouseDown: Colors.white,
  iconNormal: Colors.white,
  iconMouseOver: Colors.white,
  normal: Colors.white,
);

final minButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: const Color(0xFF805306),
  iconMouseOver: Colors.white,
);
