import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/presentation/auth/screens/user_info_desktop.dart';
import 'package:nex_music/presentation/setting/screen/desktop_setting.dart';

class DesktopSettingTab extends StatelessWidget {
  final User currentUser;

  const DesktopSettingTab({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.person),
                text: 'Profile',
              ),
              Tab(
                icon: Icon(Icons.tune),
                text: 'Setting',
              ),
            ],
            splashBorderRadius: BorderRadius.circular(12),
            enableFeedback: false,
          ),
          Expanded(
            child: TabBarView(
              children: [
                UserInfoDesktop(
                  currentUser: currentUser,
                ),
                const DesktopSetting(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
