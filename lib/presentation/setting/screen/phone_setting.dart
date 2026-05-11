
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/theme_bloc/bloc/theme_bloc.dart';
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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoadedState ? themeState.isDark : false;
        final bgColor = isDark ? const Color(0xFF000000) : kAppleBackgroundColor;
        final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
        final textPrimary = isDark ? Colors.white : Colors.black;
        final textSecondary = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E72);
        final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  _buildSectionHeader("ACCOUNT", textSecondary),
                  _buildGroupedContainer(cardColor, [
                    _buildSettingsTile(
                      context,
                      title: "Profile",
                      icon: CupertinoIcons.person_crop_circle,
                      iconColor: Colors.blue,
                      textColor: textPrimary,
                      dividerColor: dividerColor,
                      onTap: () => context.push(RouterPath.userInfoRoute),
                    ),
                  ]),

                  _buildSectionHeader("PREFERENCES", textSecondary),
                  _buildGroupedContainer(cardColor, [
                    _buildSettingsTile(
                      context,
                      title: "Quality Settings",
                      icon: CupertinoIcons.slider_horizontal_3,
                      iconColor: Colors.grey,
                      textColor: textPrimary,
                      dividerColor: dividerColor,
                      onTap: () => context.push(RouterPath.qualityRoute),
                    ),
                    Divider(height: 1, indent: 56, endIndent: 0, color: dividerColor),
                    ValueListenableBuilder<bool>(
                      valueListenable: _recommendationNotifier,
                      builder: (context, value, _) {
                        return _buildSwitchTile(
                          title: "Recommendations",
                          icon: CupertinoIcons.sparkles,
                          iconColor: Colors.orange,
                          textColor: textPrimary,
                          value: value,
                          onChanged: (newValue) async {
                            await _hiveDbInstance.saveRecommendation(newValue);
                            _recommendationNotifier.value = newValue;
                          },
                        );
                      },
                    ),
                    Divider(height: 1, indent: 56, endIndent: 0, color: dividerColor),
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) {
                        final dark = state is ThemeLoadedState ? state.isDark : false;
                        return _buildSwitchTile(
                          title: "Dark Mode",
                          icon: CupertinoIcons.moon_fill,
                          iconColor: const Color(0xFF5856D6),
                          textColor: textPrimary,
                          value: dark,
                          onChanged: (_) =>
                              context.read<ThemeBloc>().add(ToggleThemeEvent()),
                        );
                      },
                    ),
                  ]),

                  _buildSectionHeader("SESSION", textSecondary),
                  _buildGroupedContainer(cardColor, [
                    _buildSettingsTile(
                      context,
                      title: "Sign Out",
                      icon: CupertinoIcons.arrow_right_square,
                      iconColor: CupertinoColors.systemRed,
                      textColor: CupertinoColors.systemRed,
                      dividerColor: dividerColor,
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
      },
    );
  }

  Widget _buildSectionHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 20),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildGroupedContainer(Color cardColor, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
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
    Color dividerColor = const Color(0xFFC6C6C8),
    bool showChevron = true,
  }) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.transparent,
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
          ? Icon(CupertinoIcons.chevron_forward, color: dividerColor, size: 18)
          : null,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      tileColor: Colors.transparent,
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
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: CupertinoColors.activeGreen,
        onChanged: onChanged,
      ),
    );
  }
}
