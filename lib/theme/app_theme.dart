import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3); // Blau
  static const Color accentColor = Color(0xFF4CAF50); // Grün
  static const Color errorColor = Color(0xFFF44336); // Rot
  static const Color backgroundColor = Color(0xFFF5F5F5); // Helles Grau
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF212121); // Dunkelgrau
  static const Color secondaryTextColor = Color(0xFF757575); // Mittelgrau

  static final _baseTheme = ThemeData(
    primaryColor: primaryColor,
    cardTheme: const CardTheme(
      elevation: 4,
      margin: EdgeInsets.all(8),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 73, 142, 199),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: cardColor,
      elevation: 2,
    ),
  );

  static ThemeData get lightTheme => _baseTheme.copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        cardTheme: _baseTheme.cardTheme.copyWith(
          color: cardColor,
        ),
        textTheme: _baseTheme.textTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
      );

  static ThemeData get darkTheme => _baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: _baseTheme.cardTheme.copyWith(
          color: const Color(0xFF1E1E1E),
        ),
        textTheme: _baseTheme.textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 2,
          scrimColor: Colors.black54,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? primaryColor
                : Colors.grey;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? primaryColor.withOpacity(0.5)
                : Colors.grey.withOpacity(0.5);
          }),
        ),
      );
}
