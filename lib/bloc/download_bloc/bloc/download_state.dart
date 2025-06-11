part of 'download_bloc.dart';

sealed class DownloadState {}

final class DownloadInitial extends DownloadState {}

final class DownloadPercantageStatusState extends DownloadState {
  final Stream<double> percentageStream;

  DownloadPercantageStatusState({required this.percentageStream});
}
