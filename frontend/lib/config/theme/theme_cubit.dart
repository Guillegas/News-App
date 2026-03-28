import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Simple Cubit that toggles between light and dark theme modes.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDark => state == ThemeMode.dark;
}
