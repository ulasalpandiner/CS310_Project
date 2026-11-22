import 'package:flutter/material.dart';

class AppColors {
  // Official Sabancı communication guide: Pantone 280, 382, 7534 and 202.
  static const navy = Color(0xFF002776);
  static const lime = Color(0xFFBDCE1C);
  static const sand = Color(0xFFD8D4C8);
  static const error = Color(0xFF822333);

  static const ink = Color(0xFF131D34);
  static const muted = Color(0xFF495971);
  static const canvas = Color(0xFFF4F6FA);
  static const soft = Color(0xFFE9EFFA);
  static const line = Color(0xFFD5DFEE);
  static const control = Color(0xFF7487A5);
  static const white = Colors.white;
}

class AppSpacing {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double page = 20;
  static const double extraLarge = 24;
}

class AppText {
  static const family = 'RobotoCampus';

  static const display = TextStyle(
    color: AppColors.ink,
    fontSize: 34,
    height: 1.06,
    letterSpacing: -1.25,
    fontWeight: FontWeight.w800,
  );
  static const heading = TextStyle(
    color: AppColors.ink,
    fontSize: 22,
    height: 1.17,
    letterSpacing: -.45,
    fontWeight: FontWeight.w700,
  );
  static const eyebrow = TextStyle(
    color: AppColors.navy,
    fontSize: 11,
    height: 1.35,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w800,
  );
  static const note = TextStyle(
    color: AppColors.muted,
    fontSize: 13,
    height: 1.4,
  );
  static const price = TextStyle(
    color: AppColors.navy,
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w800,
  );
}

ThemeData campusMarketTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.navy).copyWith(
    primary: AppColors.navy,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.soft,
    onPrimaryContainer: AppColors.navy,
    secondary: AppColors.navy,
    secondaryContainer: AppColors.lime,
    onSecondaryContainer: AppColors.ink,
    surface: AppColors.white,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    outline: AppColors.control,
    outlineVariant: AppColors.line,
    error: AppColors.error,
    onError: AppColors.white,
  );
  final base = ThemeData(
    colorScheme: scheme,
    fontFamily: AppText.family,
    useMaterial3: true,
  );
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  );
  final fieldRadius = BorderRadius.circular(15);
  const buttonText = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.canvas,
    textTheme: base.textTheme.copyWith(
      headlineSmall: AppText.heading,
      titleLarge: AppText.heading,
      titleMedium: const TextStyle(
        color: AppColors.ink,
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: const TextStyle(
        color: AppColors.ink,
        fontSize: 14,
        height: 1.4,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: 4,
      toolbarHeight: 58,
      titleTextStyle: TextStyle(
        fontFamily: AppText.family,
        fontSize: 20,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -.55,
        color: AppColors.ink,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.navy,
        minimumSize: const Size(48, 48),
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
        elevation: 0,
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: AppColors.control),
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
        shape: buttonShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.white,
      selectedColor: AppColors.soft,
      side: const BorderSide(color: AppColors.control),
      labelStyle: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      showCheckmark: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: fieldRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: AppColors.control),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: AppColors.navy, width: 2),
      ),
      errorMaxLines: 3,
      prefixIconColor: AppColors.muted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.navy,
      contentTextStyle: TextStyle(color: AppColors.white),
    ),
  );
}
