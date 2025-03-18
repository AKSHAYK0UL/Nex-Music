import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/quality_bloc/bloc/quality_bloc.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_quality_class.dart';

import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/presentation/setting/widget/build_option.dart';

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
    );
  }
}
