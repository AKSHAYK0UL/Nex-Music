part of 'connectivity_bloc.dart';

sealed class ConnectivityState extends Equatable {}

final class ConnectivityInitial extends ConnectivityState {
  @override
  List<Object?> get props => [];
}

final class ConnectivitySuccessState extends ConnectivityState {
  @override
  List<Object?> get props => [];
}

final class ConnectivityFailureState extends ConnectivityState {
  @override
  List<Object?> get props => [];
}

final class ConnectivityErrorState extends ConnectivityState {
  final String errorMessage;

  ConnectivityErrorState({required this.errorMessage});
  @override
  List<Object?> get props => [];
}
