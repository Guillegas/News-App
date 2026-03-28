import 'package:flutter/material.dart';

/// Symmetry brand purple used across the app (FAB, buttons, accents).
const Color kSymmetryPurple = Color(0xFF6C63FF);

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Muli',
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0XFF8B8B8B)),
      titleTextStyle: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kSymmetryPurple,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: kSymmetryPurple,
      primary: kSymmetryPurple,
      brightness: Brightness.light,
    ),
    dividerColor: const Color(0xFFE0E0E0),
    iconTheme: const IconThemeData(color: Color(0xFF8B8B8B)),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF181818),
    fontFamily: 'Muli',
    appBarTheme: const AppBarTheme(
      color: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white70),
      titleTextStyle: TextStyle(color: Colors.white70, fontSize: 18),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kSymmetryPurple,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: kSymmetryPurple,
      primary: kSymmetryPurple,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
    ),
    cardColor: const Color(0xFF252525),
    dividerColor: Colors.white12,
    iconTheme: const IconThemeData(color: Colors.white70),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF2A2A2A),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF2A2A2A),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Backward-compatible alias used in older references.
ThemeData theme() => lightTheme();
