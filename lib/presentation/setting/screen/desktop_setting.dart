import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

import 'package:nex_music/presentation/setting/widget/onlysetting.dart';

class DesktopSetting extends StatelessWidget {
  const DesktopSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            height: screenSize.height * 0.695,
            width: screenSize.width * 0.651,
            child: Card(
              color: secondaryColor,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: screenSize.width * 0.010),
                      child: Lottie.asset(
                        "assets/setting.json",
                        height: screenSize.height * 0.605,
                        width: screenSize.height * 0.612,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  VerticalDivider(
                    thickness: 1.5,
                    indent: 10,
                    endIndent: 10,
                    color: accentColor,
                  ),
                  const Expanded(
                    flex: 1,
                    // width: screenSize.width * 0.309,
                    child: QualitySetting(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
