part of 'songstream_bloc.dart';

sealed class SongstreamState {}

final class SongstreamInitial extends SongstreamState {}

final class LoadingState extends SongstreamState {}

final class ErrorState extends SongstreamState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

final class StreamSongUrlState extends SongstreamState {
  final Uri songurl;

  StreamSongUrlState({required this.songurl});
}
