import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/quality_bloc/bloc/quality_bloc.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_quality_class.dart';

import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/presentation/setting/widget/build_option.dart';
=======
import 'package:nex_music/enum/thumbnail_audio_quallity.dart';
>>>>>>> c369219eb22f24aac098b98a10db839c0a2caa9c

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

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Setting'),
      ),
      body: BlocListener<QualityBloc, QualityState>(
        listener: (context, state) {
          if (state is SuccessState) {
            print("DATA SAVED");
            showSnackbar(context, screenSize, "Changes Applied");
          }
          if (state is ErrorState) {
            print(state.errorMassage);
          }
          if (state is QualityDataState) {
            print("THUMBNAIL : ${state.data.thumbnailQuality}");
            print("AUDIOSTREAM : ${state.data.audioQuality}");
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildQualityOptions(context, ThumbnailQuality.values,
                  thumbnailQualityNotifier, 'Artwork Quality'),
              const SizedBox(height: 35),
              buildQualityOptions(context, AudioQuality.values,
                  audioQualityNotifier, 'Audio Quality'),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: backgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          fixedSize: const Size(360, 47),
        ),
        onPressed: () {
          context.read<QualityBloc>().add(
                SaveQualityEvent(
                  hiveQuality: HiveQuality(
                      thumbnailQuality: thumbnailQualityNotifier.value,
                      audioQuality: audioQualityNotifier.value),
                ),
              );
        },
        child: const Text("Apply"),
      ),
=======
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
>>>>>>> c369219eb22f24aac098b98a10db839c0a2caa9c
    );
  }
}
