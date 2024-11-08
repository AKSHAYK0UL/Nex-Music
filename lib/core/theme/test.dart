import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final double bufferValue;
  final double maxValue;
  final Function(double) onChanged;
  final Function(double) onChangeEnd;

  const CustomSlider({
    super.key,
    required this.value,
    required this.bufferValue,
    required this.maxValue,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 10),
      painter: TrackPainter(
          value: value, bufferValue: bufferValue, maxValue: maxValue),
      child: Slider(
        value: value,
        min: 0,
        max: 1,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
        activeColor: Colors.transparent, // Track color is painted manually
        inactiveColor: Colors.transparent, // Inactive track is painted manually
        thumbColor: accentColor, // Thumb color is accent color
      ),
    );
  }
}

class TrackPainter extends CustomPainter {
  final double value;
  final double bufferValue;
  final double maxValue;

  TrackPainter(
      {required this.value, required this.bufferValue, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    Paint activePaint = Paint()
      ..color = accentColor // Played track (accent color)
      ..style = PaintingStyle.fill;

    Paint bufferedPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5) // Buffered track (grey color)
      ..style = PaintingStyle.fill;

    Paint trackPaint = Paint()
      ..color = textColor // Track color (text color)
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0;

    double trackWidth = size.width;

    // Draw the background track (inactive portion)
    canvas.drawRect(Rect.fromLTWH(0, 0, trackWidth, size.height), trackPaint);

    // Draw buffered portion
    double bufferedWidth = trackWidth * (bufferValue / maxValue);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, bufferedWidth, size.height), bufferedPaint);

    // Draw played portion (active track)
    double playedWidth = trackWidth * (value / maxValue);
    canvas.drawRect(Rect.fromLTWH(0, 0, playedWidth, size.height), activePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
