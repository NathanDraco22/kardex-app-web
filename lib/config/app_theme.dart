import 'package:flutter/material.dart';

class AppTheme {
  ThemeData get lightTheme => ThemeData.light(useMaterial3: false).copyWith(
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.white,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      elevation: 1.0,
      backgroundColor: Color.fromARGB(255, 52, 57, 92),
    ),
    scaffoldBackgroundColor: Colors.indigo.shade50,
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isCollapsed: true,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
    ),
  );
}
