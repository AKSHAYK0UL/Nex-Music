part of 'theme_bloc.dart';

sealed class ThemeEvent {
  const ThemeEvent();
}

final class GetThemeEvent extends ThemeEvent {}

final class ToggleThemeEvent extends ThemeEvent {}
