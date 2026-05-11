import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/core/services/hive_singleton.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final HiveDataBaseSingleton _dbInstance;

  ThemeBloc(this._dbInstance) : super(ThemeInitial()) {
    on<GetThemeEvent>(_getTheme);
    on<ToggleThemeEvent>(_toggleTheme);
  }

  Future<void> _getTheme(
      GetThemeEvent event, Emitter<ThemeState> emit) async {
    final isDark = _dbInstance.isDarkMode;
    emit(ThemeLoadedState(isDark: isDark));
  }

  Future<void> _toggleTheme(
      ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final current = state is ThemeLoadedState
        ? (state as ThemeLoadedState).isDark
        : false;
    final newValue = !current;
    await _dbInstance.saveDarkMode(newValue);
    emit(ThemeLoadedState(isDark: newValue));
  }
}
