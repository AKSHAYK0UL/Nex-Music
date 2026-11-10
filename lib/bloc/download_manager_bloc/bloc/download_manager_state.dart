part of 'download_manager_bloc.dart';

// Immutable state holding all known download tasks keyed by song vId.
final class DownloadManagerState {
  // Active/queued/paused/completed/errored tasks.
  final Map<String, DownloadTaskModel> tasks;

  const DownloadManagerState({required this.tasks});

  factory DownloadManagerState.initial() =>
      const DownloadManagerState(tasks: {});

  // Returns a copy with the task for vId updated/added.
  DownloadManagerState withTask(String vId, DownloadTaskModel task) {
    return DownloadManagerState(tasks: {...tasks, vId: task});
  }

  // Returns a copy with the task for vId removed.
  DownloadManagerState withoutTask(String vId) {
    final updated = Map<String, DownloadTaskModel>.from(tasks);
    updated.remove(vId);
    return DownloadManagerState(tasks: updated);
  }

  // Tasks that are currently visible in the UI not yet completed/removed.
  List<DownloadTaskModel> get activeTasks => tasks.values
      .where((t) =>
          t.status == DownloadTaskStatus.downloading ||
          t.status == DownloadTaskStatus.queued ||
          t.status == DownloadTaskStatus.paused ||
          t.status == DownloadTaskStatus.error)
      .toList();

  bool isDownloading(String vId) =>
      tasks[vId]?.status == DownloadTaskStatus.downloading;

  bool isPaused(String vId) =>
      tasks[vId]?.status == DownloadTaskStatus.paused;

  bool isQueued(String vId) =>
      tasks[vId]?.status == DownloadTaskStatus.queued;

  bool hasTask(String vId) => tasks.containsKey(vId);

  DownloadTaskModel? task(String vId) => tasks[vId];
}
