import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/collapsing_title_sliver_app_bar.dart';
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

  void _showApplyDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Apply Changes"),
        content: const Text(
          "Are you sure you want to apply the quality changes?",
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
                Navigator.pop(context);
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
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          CollapsingTitleSliverAppBar(
            title: "Quality Settings",
            backLabel: "Settings",
            onBackTap: () => Navigator.pop(context),
          ),
          SliverToBoxAdapter(
            child: QualitySetting(
              key: _qualitySettingKey,
              hasChangesNotifier: _hasChangesNotifier,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: ValueListenableBuilder<bool>(
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
                    onPressed: () => _showApplyDialog(context),
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
      ),
    );
  }
}
