part of 'theme_bloc.dart';

sealed class ThemeState {
  const ThemeState();
}

final class ThemeInitial extends ThemeState {}

final class ThemeLoadedState extends ThemeState {
  final bool isDark;
  const ThemeLoadedState({required this.isDark});
}
