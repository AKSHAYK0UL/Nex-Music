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
  final ValueNotifier<bool>? hasChangesNotifier;
  const QualitySetting({super.key, this.hasChangesNotifier});

  @override
  State<QualitySetting> createState() => QualitySettingState();
}

class QualitySettingState extends State<QualitySetting> {
  final ValueNotifier<ThumbnailQuality> thumbnailQualityNotifier =
      ValueNotifier<ThumbnailQuality>(ThumbnailQuality.high);
  final ValueNotifier<AudioQuality> audioQualityNotifier =
      ValueNotifier<AudioQuality>(AudioQuality.high);

  ThumbnailQuality? _initialThumbnailQuality;
  AudioQuality? _initialAudioQuality;

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

  void _checkHasChanges() {
    final hasChanges = (_initialThumbnailQuality != null &&
            thumbnailQualityNotifier.value != _initialThumbnailQuality) ||
        (_initialAudioQuality != null &&
            audioQualityNotifier.value != _initialAudioQuality);
    widget.hasChangesNotifier?.value = hasChanges;
  }

  // Exposed method for applying changes
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
    _initialThumbnailQuality = thumbnailQualityNotifier.value;
    _initialAudioQuality = audioQualityNotifier.value;
    _checkHasChanges();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtextColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return BlocListener<QualityBloc, QualityState>(
      listener: (context, state) {
        if (state is SuccessState) showSnackbar(context, "Changes Applied");
        if (state is QualityDataState) {
          _initialThumbnailQuality ??= state.data.thumbnailQuality;
          _initialAudioQuality ??= state.data.audioQuality;
          thumbnailQualityNotifier.value = state.data.thumbnailQuality;
          audioQualityNotifier.value = state.data.audioQuality;
          _checkHasChanges();
        }
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, "ARTWORK VISUALS", subtextColor),
            _buildGroupedContainer(context, [
              _buildRadioList(
                  ThumbnailQuality.values, thumbnailQualityNotifier),
            ]),
            _buildSectionHeader(context, "STREAMING AUDIO", subtextColor),
            _buildGroupedContainer(context, [
              _buildRadioList(AudioQuality.values, audioQualityNotifier),
            ]),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              child: Text(
                "Higher quality uses more data and may take longer to load.",
                style: TextStyle(color: subtextColor, fontSize: 12),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 8, top: 20),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildGroupedContainer(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRadioList<T extends Enum>(
      List<T> values, ValueNotifier<T> notifier) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<T>(
      valueListenable: notifier,
      builder: (context, currentSelection, _) {
        return Column(
          children: values.map((value) {
            final isLast = values.last == value;
            return Column(
              children: [
                ListTile(
                  onTap: () {
                    notifier.value = value;
                    _checkHasChanges();
                  },
                  tileColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  title: Text(
                    value.name.substring(0, 1).toUpperCase() +
                        value.name.substring(1).toLowerCase(),
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 17,
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: currentSelection == value
                      ? const Icon(CupertinoIcons.check_mark,
                          color: CupertinoColors.destructiveRed, size: 20)
                      : null,
                ),
                if (!isLast)
                  Divider(height: 0.5, indent: 16, color: theme.dividerColor),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
