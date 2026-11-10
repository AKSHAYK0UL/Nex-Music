import 'package:nex_music/model/songmodel.dart';

enum DownloadTaskStatus { queued, downloading, paused, completed, error }

class DownloadTaskModel {
  final Songmodel songData;
  final DownloadTaskStatus status;
  final double progress; // 0.0  100.0
  final String? errorMessage;
  final int downloadedBytes; // bytes saved so far (for resume)

  const DownloadTaskModel({
    required this.songData,
    required this.status,
    this.progress = 0.0,
    this.errorMessage,
    this.downloadedBytes = 0,
  });

  DownloadTaskModel copyWith({
    Songmodel? songData,
    DownloadTaskStatus? status,
    double? progress,
    String? errorMessage,
    int? downloadedBytes,
  }) {
    return DownloadTaskModel(
      songData: songData ?? this.songData,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    );
  }

  bool get isActive =>
      status == DownloadTaskStatus.downloading ||
      status == DownloadTaskStatus.queued;

  bool get isPaused => status == DownloadTaskStatus.paused;
  bool get isCompleted => status == DownloadTaskStatus.completed;
  bool get isError => status == DownloadTaskStatus.error;
}
