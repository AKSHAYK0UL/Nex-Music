import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  ConnectivityBloc(this._connectivity) : super(ConnectivityInitial()) {
    on<CheckConnectivityStatusEvent>(_connectivityStatus);
  }
  Future<void> _connectivityStatus(CheckConnectivityStatusEvent event,
      Emitter<ConnectivityState> emit) async {
    try {
      final connection = await _connectivity.checkConnectivity();
      if (connection.contains(ConnectivityResult.none)) {
        emit(ConnectivityFailureState());
      } else {
        emit(ConnectivitySuccessState());
      }
    } catch (e) {
      emit(ConnectivityErrorState(errorMessage: e.toString()));
    }
  }
}
