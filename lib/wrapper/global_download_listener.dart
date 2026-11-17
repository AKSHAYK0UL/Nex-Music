import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/download_manager_bloc/bloc/download_manager_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/model/download_task_model.dart';

// Listens to DownloadManagerBloc globally and reloads offline songs
// whenever any download completes, and persists active downloads on app lifecycle changes.
class GlobalDownloadListenerWrapper extends StatefulWidget {
  final Widget child;

  const GlobalDownloadListenerWrapper({super.key, required this.child});

  @override
  State<GlobalDownloadListenerWrapper> createState() =>
      _GlobalDownloadListenerWrapperState();
}

class _GlobalDownloadListenerWrapperState
    extends State<GlobalDownloadListenerWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      try {
        context.read<DownloadManagerBloc>().persistActiveDownloads();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloadManagerBloc, DownloadManagerState>(
      listenWhen: (previous, current) {
        // Fire only when a task transitions to completed or error.
        // Pausing, resuming, or progressing should NEVER trigger an offline songs reload.
        for (final vId in current.tasks.keys) {
          final prev = previous.task(vId);
          final curr = current.task(vId);
          if (curr == null) continue;
          if (prev?.status != curr.status &&
              (curr.status == DownloadTaskStatus.completed ||
                  curr.status == DownloadTaskStatus.error)) {
            return true;
          }
        }
        return false;
      },
      listener: (context, state) {
        for (final entry in state.tasks.entries) {
          final task = entry.value;
          if (task.status == DownloadTaskStatus.completed) {
            context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
          }
          if (task.status == DownloadTaskStatus.error) {
            showSnackbar(context, task.errorMessage ?? 'Download failed');
          }
        }
      },
      child: widget.child,
    );
  }
}
