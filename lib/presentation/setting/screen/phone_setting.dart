import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/presentation/auth/screens/user_info.dart' as user;
import 'package:nex_music/presentation/setting/screen/settting.dart';
import 'package:nex_music/presentation/setting/widget/phone_setting_option.dart';

class Setting extends StatelessWidget {
  static const routeName = "/setting";

  Setting({super.key});

  final _hiveDbInstance = HiveDataBaseSingleton.instance;
  final ValueNotifier<bool> _recommendationNotifier = ValueNotifier<bool>(
    HiveDataBaseSingleton.instance.recommendationStatus,
  );

  @override
  Widget build(BuildContext context) {
    final User routeData = ModalRoute.of(context)?.settings.arguments as User;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
      ),
      body: Column(
        children: [
          PhoneSettingOptionTitle(
            title: "Account",
            icon: Icons.person,
            onTap: () {
              Navigator.of(context)
                  .pushNamed(user.UserInfo.routeName, arguments: routeData);
            },
          ),
          PhoneSettingOptionTitle(
            title: "Quality Setting",
            icon: Icons.tune,
            onTap: () {
              Navigator.of(context).pushNamed(QualitySettingsScreen.routeName);
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _recommendationNotifier,
            builder: (context, value, _) {
              return Container(
                margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.030,
                    vertical: screenHeight * 0.0055),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.050,
                      vertical: screenHeight * 0.0130),
                  secondary: CircleAvatar(
                    radius: 23,
                    backgroundColor: backgroundColor,
                    child: Icon(
                      Icons.person_search_outlined,
                      color: textColor,
                      size: 27,
                    ),
                  ),
                  activeTrackColor: accentColor,
                  inactiveTrackColor: backgroundColor,
                  thumbColor: WidgetStateProperty.resolveWith((_) {
                    return value ? backgroundColor : accentColor;
                  }),
                  title: Text(
                    "Recommendation",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  value: value,
                  onChanged: (newValue) async {
                    await _hiveDbInstance.saveRecommendation(newValue);
                    _recommendationNotifier.value = newValue;
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
