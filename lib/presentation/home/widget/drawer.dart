import 'package:flutter/material.dart';
import 'package:nex_music/presentation/auth/screens/user_info.dart';
import 'package:nex_music/presentation/setting/screen/settting.dart';

class BuildDrawer extends StatelessWidget {
  const BuildDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Container(
                height: 50,
              )),
          buildDrawertitle(
              context, Icon(Icons.person), "Account", UserInfo.routeName),
          buildDrawertitle(context, Icon(Icons.settings), "Quality Setting",
              QualitySettingsScreen.routeName),
        ],
      ),
    );
  }
}

Widget buildDrawertitle(
    BuildContext context, Icon icon, String text, String navRoute) {
  return ListTile(
    onTap: () {
      Navigator.of(context).pushNamed(navRoute);
    },
    leading: CircleAvatar(
      child: icon,
    ),
    title: Text(text),
  );
}
