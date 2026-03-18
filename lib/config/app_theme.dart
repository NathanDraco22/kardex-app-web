import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColourPalette {
  static const Color deepBackground = Color(0xFF072a3c);
  static const Color primary = Color(0xFF072a3c);
  // static const Color primary = Color(0xFF162b4e);
  static const Color primaryVariant = Color(0xFF3B62A1);
  static const Color secondary = Color(0xFF3B62A1);
  static const Color primaryInverse = Colors.amber;
  // static const Color softWhiteAliceBlue = Color(0xFFF0F8FF);
}

class AppTheme {
  ThemeData get lightTheme => ThemeData.light(useMaterial3: false).copyWith(
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light(useMaterial3: false).textTheme,
    ),
    dialogTheme: const DialogThemeData(
      constraints: BoxConstraints(minWidth: 600, maxWidth: 600),
      insetPadding: EdgeInsets.zero,
    ),
    colorScheme: const ColorScheme.light(
      primary: ColourPalette.primaryVariant,
      secondary: ColourPalette.secondary,
      primaryContainer: ColourPalette.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: ColourPalette.primaryInverse,
      linearTrackColor: Colors.amber.shade100,
      circularTrackColor: Colors.amber.shade100,
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      elevation: 1.0,
      backgroundColor: ColourPalette.primary,
    ),
    scaffoldBackgroundColor: Colors.indigo.shade50,
    dropdownMenuTheme: const DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 1.5),
      ),
      isCollapsed: true,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
    ),
  );
}
