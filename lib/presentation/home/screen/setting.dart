import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/presentation/auth/screens/user_info.dart' as user;
import 'package:nex_music/presentation/setting/screen/settting.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(user.UserInfo.routeName, arguments: routeData);
            },
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: const Text("Account"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(QualitySettingsScreen.routeName);
            },
            leading: const CircleAvatar(
              child: Icon(Icons.tune),
            ),
            title: const Text("Quality Setting"),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _recommendationNotifier,
            builder: (context, value, _) {
              return SwitchListTile(
                title: const Text("Recommendation"),
                secondary: const CircleAvatar(
                  radius: 25,
                  child: Icon(
                    Icons.person_search_outlined,
                    size: 30,
                  ),
                ),
                value: value,
                onChanged: (newValue) async {
                  await _hiveDbInstance.saveRecommendation(newValue);
                  _recommendationNotifier.value = newValue;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
