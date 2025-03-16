import 'package:flutter/material.dart';
import 'package:nex_music/enum/thumbnail_audio_quallity.dart';

class QualitySettingsScreen extends StatefulWidget {
  static const routeName = "setting";

  const QualitySettingsScreen({super.key});

  @override
  State<QualitySettingsScreen> createState() => _QualitySettingsScreenState();
}

class _QualitySettingsScreenState extends State<QualitySettingsScreen> {
  final ValueNotifier<ThumbnailQuality> thumbnailQualityNotifier =
      ValueNotifier<ThumbnailQuality>(ThumbnailQuality.high);
  final ValueNotifier<AudioQuality> audioQualityNotifier =
      ValueNotifier<AudioQuality>(AudioQuality.high);

  @override
  void dispose() {
    thumbnailQualityNotifier.dispose();
    audioQualityNotifier.dispose();
    super.dispose();
  }

  Widget _buildQualityOptions<T>(
      List<T> values, ValueNotifier<T> notifier, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ValueListenableBuilder<T>(
          valueListenable: notifier,
          builder: (context, selectedQuality, child) {
            return Column(
              children: List.generate(values.length, (index) {
                T quality = values[index];

                BorderRadius borderRadius = BorderRadius.zero;
                if (index == 0) {
                  borderRadius =
                      BorderRadius.vertical(top: Radius.circular(15));
                } else if (index == values.length - 1) {
                  borderRadius =
                      BorderRadius.vertical(bottom: Radius.circular(15));
                }

                return GestureDetector(
                  onTap: () {
                    notifier.value = quality;
                  },
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: borderRadius),
                    title:
                        Text(quality.toString().split('.').last.toUpperCase()),
                    leading: Radio<T>(
                      value: quality,
                      groupValue: selectedQuality,
                      onChanged: (value) {
                        if (value != null) {
                          notifier.value = value;
                        }
                      },
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQualityOptions(ThumbnailQuality.values,
                thumbnailQualityNotifier, 'Thumbnail Quality'),
            const SizedBox(height: 24),
            _buildQualityOptions(
                AudioQuality.values, audioQualityNotifier, 'Audio Quality'),
          ],
        ),
      ),
    );
  }
}
