part of 'homesection_bloc.dart';

sealed class HomesectionEvent {}

final class GetHomeSectonDataEvent extends HomesectionEvent {}

// Re-fetches home data in the background without emitting [LoadingState].
// HomeScreen stays on its current content while the fetch runs, then
// swaps to the new data when it arrives. Use this after settings changes
// (recommendation toggle, quality change) so the user never sees a splash.
final class RefreshHomeSilentlyEvent extends HomesectionEvent {}
