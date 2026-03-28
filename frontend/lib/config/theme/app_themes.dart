import 'package:flutter/material.dart';

/// Symmetry brand purple used across the app (FAB, buttons, accents).
const Color kSymmetryPurple = Color(0xFF6C63FF);

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Muli',
    appBarTheme: appBarTheme(),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kSymmetryPurple,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: kSymmetryPurple,
      primary: kSymmetryPurple,
    ),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0XFF8B8B8B)),
    titleTextStyle: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
  );
}
