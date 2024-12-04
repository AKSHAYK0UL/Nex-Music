part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent extends Equatable {}

final class CheckConnectivityStatusEvent extends ConnectivityEvent {
  @override
  List<Object?> get props => [];
}
