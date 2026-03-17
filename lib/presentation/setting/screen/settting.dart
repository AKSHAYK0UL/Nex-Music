
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/presentation/setting/widget/onlysetting.dart';

class QualitySettingsScreen extends StatelessWidget {
  static const routeName = "/quality-setting";

  const QualitySettingsScreen({super.key});

  void _showRestartDialog(
      BuildContext context, GlobalKey<QualitySettingState> key) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Restart Required"),
        content: const Text(
          "The app needs to restart and clear cache to apply the new quality settings. Do you want to proceed?",
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction:
                true, 

            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction:
                false, 
            onPressed: () async {
              await key.currentState?.applyChanges();

              if (context.mounted) {
                
                 Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (route) => false);

              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color iosBackgroundColor = Color(0xFFF2F2F7);
    final GlobalKey<QualitySettingState> qualitySettingKey = GlobalKey();

    return Scaffold(
      backgroundColor: iosBackgroundColor,
      appBar: AppBar(
        backgroundColor: iosBackgroundColor,
        elevation: 0,
        leadingWidth: 100,
        actionsPadding: const EdgeInsets.only(right: 15),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text(
              "Done",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: CupertinoColors.activeBlue,
              ),
            ),
            onPressed: () => _showRestartDialog(context, qualitySettingKey),
          ),
        ],
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios, color: Colors.red, size: 20),
              Text(
                'Settings',
                style: TextStyle(color: Colors.red, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
            child: Text(
              "Quality Settings",
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ),
          QualitySetting(key: qualitySettingKey),
        ],
      ),
    );
  }
}
