import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class PhoneSettingOptionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const PhoneSettingOptionTitle({
    super.key,
    required this.title,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.030, vertical: screenHeight * 0.0055),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.050, vertical: screenHeight * 0.0130),
        splashColor: Colors.transparent,
        tileColor: secondaryColor,
        leading: CircleAvatar(
          radius: 23,
          backgroundColor: backgroundColor,
          child: Icon(
            icon,
            color: textColor,
            size: 27,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}
