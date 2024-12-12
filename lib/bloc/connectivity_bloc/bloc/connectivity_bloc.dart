import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>>
      _connectivityStreamSubscription;
  ConnectivityBloc(this._connectivity) : super(ConnectivityInitial()) {
    _connectivityStreamSubscription =
        _connectivity.onConnectivityChanged.listen((connectionStatus) {
      if (connectionStatus.contains(ConnectivityResult.none)) {
        add((ConnectivityFailureEvent()));
      } else {
        add(ConnectivitySuccessEvent());
      }
    });
    on<ConnectivityFailureEvent>(
        (event, emit) => emit(ConnectivityFailureState()));
    on<ConnectivitySuccessEvent>(
        (event, emit) => emit(ConnectivitySuccessState()));
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

  @override
  Future<void> close() async {
    _connectivityStreamSubscription.cancel();
    return super.close();
  }
}
