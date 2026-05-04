import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.teal,
          surface: AppColors.card,
          error: AppColors.red,
          onPrimary: Colors.white,
          onSurface: AppColors.text,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.text,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardAlt,
          hintStyle: const TextStyle(color: AppColors.muted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: AppColors.text, fontWeight: FontWeight.w800),
          titleLarge:
              TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
          titleMedium:
              TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: AppColors.text, fontSize: 14),
          bodySmall: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700),
            elevation: 0,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xF50E1B2E),
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.dimmed,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}
