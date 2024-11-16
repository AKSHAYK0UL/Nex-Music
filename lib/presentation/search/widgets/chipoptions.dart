import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class ChipOptions extends StatelessWidget {
  final String label;
  final Function onTap;
  const ChipOptions({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Chip(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
          borderRadius: BorderRadius.circular(
            screenSize * 0.0100,
          ),
        ),
        backgroundColor: backgroundColor,
        label: SizedBox(
          width: screenSize * 0.165,
          height: screenSize * 0.0329,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
      ),
    );
  }
}
