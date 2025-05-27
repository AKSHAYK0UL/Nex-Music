import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';

Widget buildUserInfo(
    {required BuildContext context,
    required String title,
    required String data,
    required Size screenSize}) {
  bool isSmallScreen = screenSize.width < 451;

  return Container(
    // width: isSmallScreen ? double.infinity : screenSize.width * 0.309,
    margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen
            ? screenSize.height * 0.0197
            : screenSize.width * 0.0100,
        vertical: isSmallScreen
            ? screenSize.height * 0.0091
            : screenSize.height * 0.0020),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.0027,
        ),
        animatedText(
          text: data,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: screenSize.height * 0.0276),
        ),
        const Divider(
          color: Color.fromARGB(65, 255, 255, 255),
          thickness: 1.5,
        ),
      ],
    ),
  );
}
