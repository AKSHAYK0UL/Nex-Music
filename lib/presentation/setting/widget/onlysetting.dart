
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart' as hs;
import 'package:nex_music/bloc/quality_bloc/bloc/quality_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart' as sb;
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_quality_class.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/quality.dart';

class QualitySetting extends StatefulWidget {
  const QualitySetting({super.key});

  @override
  State<QualitySetting> createState() => QualitySettingState();
}

class QualitySettingState extends State<QualitySetting> {
  final ValueNotifier<ThumbnailQuality> thumbnailQualityNotifier =
      ValueNotifier<ThumbnailQuality>(ThumbnailQuality.high);
  final ValueNotifier<AudioQuality> audioQualityNotifier =
      ValueNotifier<AudioQuality>(AudioQuality.high);

  @override
  void initState() {
    context.read<QualityBloc>().add(GetQualityEvent());
    super.initState();
  }

  @override
  void dispose() {
    thumbnailQualityNotifier.dispose();
    audioQualityNotifier.dispose();
    super.dispose();
  }

  // Exposed method for the "Done" button in the AppBar
  Future<void> applyChanges() async {
    context.read<sb.SongstreamBloc>().add(sb.CloseMiniPlayerEvent());
    await DefaultCacheManager().emptyCache();

    if (!mounted) return;
    context.read<QualityBloc>().add(
          SaveQualityEvent(
            hiveQuality: HiveQuality(
                thumbnailQuality: thumbnailQualityNotifier.value,
                audioQuality: audioQualityNotifier.value),
          ),
        );
    context.read<hs.HomesectionBloc>().add(hs.GetHomeSectonDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QualityBloc, QualityState>(
      listener: (context, state) {
        if (state is SuccessState) showSnackbar(context, "Changes Applied");
        if (state is QualityDataState) {
          thumbnailQualityNotifier.value = state.data.thumbnailQuality;
          audioQualityNotifier.value = state.data.audioQuality;
        }
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("ARTWORK VISUALS"),
            _buildGroupedContainer([
              _buildRadioList(ThumbnailQuality.values, thumbnailQualityNotifier),
            ]),
            _buildSectionHeader("STREAMING AUDIO"),
            _buildGroupedContainer([
              _buildRadioList(AudioQuality.values, audioQualityNotifier),
            ]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              child: Text(
                "Higher quality uses more data and may take longer to load.",
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 8, top: 20),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6E6E72),
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildGroupedContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRadioList<T extends Enum>(
      List<T> values, ValueNotifier<T> notifier) {
    return ValueListenableBuilder<T>(
      valueListenable: notifier,
      builder: (context, currentSelection, _) {
        return Column(
          children: values.map((value) {
            final isLast = values.last == value;
            return Column(
              children: [
                ListTile(
                  onTap: () => notifier.value = value,
                  tileColor: Colors.transparent, 
                  hoverColor: Colors.transparent,
                  title: Text(
                    value.name.substring(0, 1).toUpperCase() + 
                    value.name.substring(1).toLowerCase(), 
                    style: const TextStyle(
                      fontFamily: 'serif', 
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: currentSelection == value
                      ? const Icon(CupertinoIcons.check_mark,
                          color: CupertinoColors.activeBlue, size: 20)
                      : null,
                ),
                if (!isLast)
                  const Divider(
                      height: 0.5, 
                      indent: 16, 
                      color: Color(0xFFC6C6C8)),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}