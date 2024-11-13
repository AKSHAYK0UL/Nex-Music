part of 'video_bloc.dart';

sealed class VideoEvent {}

final class SearchInVideoEvent extends VideoEvent {
  final String inputText;

  SearchInVideoEvent({required this.inputText});
}
