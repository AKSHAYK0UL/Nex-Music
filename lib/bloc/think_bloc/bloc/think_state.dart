part of 'think_bloc.dart';

sealed class ThinkState extends Equatable {
  @override
  List<Object> get props => [];
}

final class ThinkInitial extends ThinkState {}

final class ThinkErrorState extends ThinkState {
  final String errorMessage;

  ThinkErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
