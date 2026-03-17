
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/helper_function/sign_out_helper/handle_sign_out.dart';

const Color kAppleBackgroundColor = Color(0xFFF2F2F7);

class Setting extends StatelessWidget {
  static const routeName = "/setting";

  final User currentUser;

  Setting({super.key, required this.currentUser});

  final _hiveDbInstance = HiveDataBaseSingleton.instance;
  final ValueNotifier<bool> _recommendationNotifier = ValueNotifier<bool>(
    HiveDataBaseSingleton.instance.recommendationStatus,
  );

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out of Nex Music?"),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            // onPressed: () => Navigator.pop(context),
            onPressed: () =>  context.pop(),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              // if (context.mounted) {
              //   Navigator.of(context)
              //       .pushNamedAndRemoveUntil('/', (route) => false);
              // }
              try {
                // Navigator.of(context).pop();
                context.pop();
                await handleSignout(context);
              } catch (e) {
                if (!context.mounted) return;
                showSnackbar(context, "error in signing out");
              }
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // Set background to the light grey Apple color
      backgroundColor: kAppleBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              const Padding(
                padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // --- ACCOUNT SECTION ---
              _buildSectionHeader("ACCOUNT"),
              _buildGroupedContainer([
                _buildSettingsTile(
                  context,
                  title: "Profile",
                  icon: CupertinoIcons.person_crop_circle,
                  iconColor: Colors.blue,
                  onTap: () {
                    context.push(RouterPath.userInfoRoute);
                  },
                ),
              ]),

              // --- PREFERENCES SECTION ---
              _buildSectionHeader("PREFERENCES"),
              _buildGroupedContainer([
                _buildSettingsTile(
                  context,
                  title: "Quality Settings",
                  icon: CupertinoIcons.slider_horizontal_3,
                  iconColor: Colors.grey,
                  onTap: () {
                    
                    context.push(RouterPath.qualityRoute);
                  },
                ),
                const Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 0,
                    color: Color(0xFFC6C6C8)),
                ValueListenableBuilder<bool>(
                  valueListenable: _recommendationNotifier,
                  builder: (context, value, _) {
                    return _buildSwitchTile(
                      title: "Recommendations",
                      icon: CupertinoIcons.sparkles,
                      iconColor: Colors.orange,
                      value: value,
                      onChanged: (newValue) async {
                        await _hiveDbInstance.saveRecommendation(newValue);
                        _recommendationNotifier.value = newValue;
                      },
                    );
                  },
                ),
              ]),

              // --- SESSION SECTION ---
              _buildSectionHeader("SESSION"),
              _buildGroupedContainer([
                _buildSettingsTile(
                  context,
                  title: "Sign Out",
                  icon: CupertinoIcons.arrow_right_square,
                  iconColor: CupertinoColors.systemRed,
                  textColor: CupertinoColors.systemRed,
                  showChevron: false,
                  onTap: () => _showLogoutDialog(context),
                ),
              ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 20),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6E6E72),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildGroupedContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      // IMPORTANT: clipBehavior prevents children from showing "black corners"
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white, // Section background is white
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Color textColor = Colors.black,
    bool showChevron = true,
  }) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.transparent, // Prevents rectangular color bleed
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
      trailing: showChevron
          ? const Icon(CupertinoIcons.chevron_forward,
              color: Color(0xFFC6C6C8), size: 18)
          : null,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      tileColor: Colors.transparent, // Prevents rectangular color bleed
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'serif',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: CupertinoColors.activeGreen,
        onChanged: onChanged,
      ),
    );
  }
}
