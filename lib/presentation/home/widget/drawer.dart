import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/signing_out_loading.dart';
import 'package:nex_music/presentation/auth/screens/user_info.dart' as user;
import 'package:nex_music/presentation/setting/screen/settting.dart';

class BuildDrawer extends StatelessWidget {
  final User currentUser;

  const BuildDrawer({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 2),
              child: Lottie.asset(
                "assets/guitar.json",
                fit: BoxFit.fill,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
          ),
          buildDrawertitle(
              context,
              const Icon(
                Icons.person,
                size: 29,
              ),
              "Account", () {
            Navigator.of(context)
                .pushNamed(user.UserInfo.routeName, arguments: currentUser);
          }),
          buildDrawertitle(
            context,
            const Icon(
              Icons.settings,
              size: 29,
            ),
            "Quality Setting",
            () {
              Navigator.of(context).pushNamed(QualitySettingsScreen.routeName);
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: TextButton.icon(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Are You Sure?"),
                    content: const Text("Do you want to Logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SigningOutLoading()));
                        },
                        child: const Text("Yes"),
                      )
                    ],
                  ),
                );
              },
              label: Text(
                "SignOut",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.red),
              ),
              icon: const Icon(
                Icons.logout,
                size: 27,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget buildDrawertitle(
    BuildContext context, Icon icon, String text, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    child: ListTile(
      splashColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(8.5),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: accentColor,
        foregroundColor: secondaryColor,
        child: icon,
      ),
      title: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    ),
  );
}
