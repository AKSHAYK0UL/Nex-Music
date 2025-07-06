import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class ChipWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function onTap;
  const ChipWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: SizedBox(
        // width: screenSize * 0.161,
        width: screenWidth * 0.290,

        // height: screenHeight * 0.0721,
        child: Chip(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              SizedBox(
                width: screenWidth * 0.0105,
              ),
              Icon(
                icon,
                color: textColor,
                size: screenHeight * 0.0316,
              )
            ],
          ),
        ),
      ),
    );
  }
}
