part of 'quality_bloc.dart';

sealed class QualityEvent {
  const QualityEvent();
}

final class SaveQualityEvent extends QualityEvent {
  final HiveQuality hiveQuality;

  SaveQualityEvent({required this.hiveQuality});
}

final class GetQualityEvent extends QualityEvent {}
