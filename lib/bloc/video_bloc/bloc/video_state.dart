part of 'video_bloc.dart';

sealed class VideoState {}

final class VideoInitial extends VideoState {}

final class LoadingState extends VideoState {}

final class ErrorState extends VideoState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

final class VideosResultState extends VideoState {
  final List<Songmodel> searchedVideo;

  VideosResultState({required this.searchedVideo});
}
