part of 'quality_bloc.dart';

sealed class QualityState {
  const QualityState();
}

final class QualityInitial extends QualityState {}

final class LoadingState extends QualityState {}

final class QualityDataState extends QualityState {
  final HiveQuality data;

  QualityDataState({required this.data});
}

final class SuccessState extends QualityState {}

final class ErrorState extends QualityState {
  final String errorMassage;

  ErrorState({required this.errorMassage});
}
