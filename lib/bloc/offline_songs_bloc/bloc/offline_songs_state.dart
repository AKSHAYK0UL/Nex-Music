part of 'offline_songs_bloc.dart';

sealed class OfflineSongsState {}

final class OfflineSongsInitial extends OfflineSongsState {}

final class OfflineSongsLoadingState extends OfflineSongsState {}

final class OfflineSongsErrorState extends OfflineSongsState {
  final String errorMessage;

  OfflineSongsErrorState({required this.errorMessage});
}

final class OfflineSongsDataState extends OfflineSongsState {
  final Stream<List<Songmodel>> data;

  OfflineSongsDataState({required this.data});
}
