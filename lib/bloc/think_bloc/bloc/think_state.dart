part of 'think_bloc.dart';

sealed class ThinkState extends Equatable {
  const ThinkState();
  
  @override
  List<Object> get props => [];
}

final class ThinkInitial extends ThinkState {}
