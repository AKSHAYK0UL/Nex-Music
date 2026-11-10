import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/download_manager_bloc/bloc/download_manager_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/download_task_model.dart';

// In progress download row.

class ActiveDownloadTile extends StatelessWidget {
  final DownloadTaskModel task;

  const ActiveDownloadTile({super.key, required this.task});

  //  Status colours 
  static const _kRed = Color(0xFFFF2D55);
  static const _kOrange = Color(0xFFFF9500);
  static const _kGrey = Color(0xFF8E8E93);

  Color _statusColor(DownloadTaskStatus s) {
    switch (s) {
      case DownloadTaskStatus.downloading:
        return _kRed;
      case DownloadTaskStatus.paused:
        return _kOrange;
      default:
        return _kGrey;
    }
  }

  //  Subtitle: only status + download %

  Widget _buildSubtitle(DownloadTaskModel task, ThemeData theme) {
    final color = _statusColor(task.status);
    final progress = task.progress.clamp(0.0, 100.0).toInt();

    String label;
    switch (task.status) {
      case DownloadTaskStatus.downloading:
        label = 'Downloading · $progress%';
        break;
      case DownloadTaskStatus.paused:
        label = 'Paused · $progress%';
        break;
      case DownloadTaskStatus.queued:
        label = 'Waiting…';
        break;
      case DownloadTaskStatus.error:
        label = task.errorMessage ?? 'Error';
        break;
      default:
        label = '';
    }

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: -0.1,
      ),
    );
  }

  // Delete confirmation dialog 
  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cancel Download'),
        content: Text(
          'Cancel downloading "${task.songData.songName}"?\n'
          'Any partially downloaded data will be removed.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<DownloadManagerBloc>()
                  .add(CancelDownloadEvent(vId: task.songData.vId));
              context
                  .read<OfflineSongsBloc>()
                  .add(LoadOfflineSongsEvent());
            },
            child: const Text('Cancel Download'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final song = task.songData;

    final double progress = task.progress.clamp(0.0, 100.0);
    final bool isQueued = task.status == DownloadTaskStatus.queued;
    final bool isDownloading = task.status == DownloadTaskStatus.downloading;
    final bool isPaused = task.status == DownloadTaskStatus.paused;
    final Color statusColor = _statusColor(task.status);

    return SizedBox(
      height: 85,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: cacheImage(
                  imageUrl: song.thumbnail,
                  width: 70,
                  height: 70,
                  islocal: song.isLocal,
                ),
              ),
            ),

            const SizedBox(width: 16),

            //  Text + icons + progress bar
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content row: title + subtitle + action icons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.songName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildSubtitle(task, theme),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: isDownloading
                            ? _ActionIcon(
                                icon: CupertinoIcons.pause_fill,
                                onTap: () => context
                                    .read<DownloadManagerBloc>()
                                    .add(PauseDownloadEvent(vId: song.vId)),
                              )
                            : isPaused
                                ? _ActionIcon(
                                    icon: CupertinoIcons.play_fill,
                                    onTap: () => context
                                        .read<DownloadManagerBloc>()
                                        .add(ResumeDownloadEvent(
                                            vId: song.vId)),
                                  )
                                : const SizedBox(width: 8),
                      ),

                      const SizedBox(width: 8),

                      // Trash 
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _ActionIcon(
                          icon: CupertinoIcons.trash,
                          color: const Color(0xFFFF3B30),
                          onTap: () => _confirmDelete(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: isQueued ? null : progress / 100,
                      minHeight: 1.5,
                      backgroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: isDark ? 0.15 : 0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
      ),
    );
  }
}
