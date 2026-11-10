import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/download_manager_bloc/bloc/download_manager_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/model/download_task_model.dart';

// Listens to DownloadManagerBloc globally and reloads offline songs
// whenever any download completes.
class GlobalDownloadListenerWrapper extends StatelessWidget {
  final Widget child;

  const GlobalDownloadListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloadManagerBloc, DownloadManagerState>(
      listenWhen: (previous, current) {
        // Fire whenever any task transitions to completed or error.
        for (final vId in current.tasks.keys) {
          final prev = previous.task(vId);
          final curr = current.task(vId);
          if (prev == null) continue;
          if (prev.status != curr?.status) return true;
        }
        // Also fire when a task is removed (completed task cleaned up).
        if (previous.tasks.length != current.tasks.length) return true;
        return false;
      },
      listener: (context, state) {
        for (final entry in state.tasks.entries) {
          // Only react to freshly completed tasks.
          final task = entry.value;
          if (task.status == DownloadTaskStatus.completed) {
            context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
            return;
          }
          if (task.status == DownloadTaskStatus.error) {
            showSnackbar(context, task.errorMessage ?? 'Download failed');
          }
        }
        // If a task was removed (completed task evicted), reload.
        context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
      },
      child: child,
    );
  }
}
