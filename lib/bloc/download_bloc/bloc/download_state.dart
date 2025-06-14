part of 'download_bloc.dart';

sealed class DownloadState {}

final class DownloadInitial extends DownloadState {}

final class DownloadPercantageStatusState extends DownloadState {
  final Songmodel songData;
  final Stream<double> percentageStream;

  DownloadPercantageStatusState(
      {required this.percentageStream, required this.songData});
  DownloadPercantageStatusState copyWith(
      {Songmodel? songData, Stream<double>? percentageStream}) {
    return DownloadPercantageStatusState(
        songData: songData ?? this.songData,
        percentageStream: percentageStream ?? this.percentageStream);
  }
}

final class DownloadCompletedState extends DownloadState {}

final class DownloadErrorState extends DownloadState {
  final String errorMessage;

  DownloadErrorState({required this.errorMessage});
}
