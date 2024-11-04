// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    final screenSize = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: SizedBox(
        width: screenSize * 0.148,
        height: screenSize * 0.0721,
        child: Chip(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              SizedBox(
                width: screenSize * 0.0105,
              ),
              Icon(
                icon,
                color: textColor,
                size: screenSize * 0.0316,
              )
            ],
          ),
        ),
      ),
    );
  }
}
