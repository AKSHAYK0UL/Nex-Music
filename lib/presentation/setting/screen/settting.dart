
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/presentation/setting/widget/onlysetting.dart';

class QualitySettingsScreen extends StatefulWidget {
  static const routeName = "/quality-setting";

  const QualitySettingsScreen({super.key});

  @override
  State<QualitySettingsScreen> createState() => _QualitySettingsScreenState();
}

class _QualitySettingsScreenState extends State<QualitySettingsScreen> {
  final GlobalKey<QualitySettingState> _qualitySettingKey = GlobalKey();
  final ValueNotifier<bool> _hasChangesNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _hasChangesNotifier.dispose();
    super.dispose();
  }

  void _showRestartDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Restart Required"),
        content: const Text(
          "The app needs to restart and clear cache to apply the new quality settings. Do you want to proceed?",
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: false,
            onPressed: () async {
              await _qualitySettingKey.currentState?.applyChanges();

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_ios, color: Colors.red, size: 20),
              Text(
                'Settings',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 17,
                  backgroundColor: theme.scaffoldBackgroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
            child: Text(
              "Quality Settings",
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Expanded(
            child: QualitySetting(
              key: _qualitySettingKey,
              hasChangesNotifier: _hasChangesNotifier,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: _hasChangesNotifier,
        builder: (context, hasChanges, child) {
          if (!hasChanges) {
            return const SizedBox.shrink();
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showRestartDialog(context),
                  child: const Text(
                    "Apply Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

