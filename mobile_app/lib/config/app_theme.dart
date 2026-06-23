import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static List<ThemeData> get all => [darkNavy, lightDay, midnight, sunset, ocean];

  static ThemeData forIndex(int i) => all[i.clamp(0, all.length - 1)];

  // ── Dark Navy (default) ────────────────────────────────────────────────
  static ThemeData get darkNavy => _build(WageColors.darkNavy, Brightness.dark);

  // ── Light Day ─────────────────────────────────────────────────────────
  static ThemeData get lightDay => _build(WageColors.lightDay, Brightness.light);

  // ── Midnight (AMOLED) ─────────────────────────────────────────────────
  static ThemeData get midnight => _build(WageColors.midnight, Brightness.dark);

  // ── Sunset ────────────────────────────────────────────────────────────
  static ThemeData get sunset => _build(WageColors.sunset, Brightness.dark);

  // ── Ocean ─────────────────────────────────────────────────────────────
  static ThemeData get ocean => _build(WageColors.ocean, Brightness.dark);

  // ── Legacy getter used by old code ────────────────────────────────────
  static ThemeData get dark => darkNavy;

  // ── Builder ───────────────────────────────────────────────────────────
  static ThemeData _build(WageColors c, Brightness brightness) => ThemeData(
        brightness: brightness,
        scaffoldBackgroundColor: c.bg,
        extensions: [c],
        colorScheme: ColorScheme(
          brightness: brightness,
          primary: c.accent,
          onPrimary: Colors.white,
          secondary: c.accentAlt,
          onSecondary: Colors.white,
          error: c.red,
          onError: Colors.white,
          surface: c.card,
          onSurface: c.text,
        ),
        cardColor: c.card,
        dividerColor: c.border,
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: c.text, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: c.text, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(color: c.text, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: c.text, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: c.text),
          bodyMedium: TextStyle(color: c.muted),
          labelLarge: TextStyle(color: c.accent, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: c.cardAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.accent, width: 1.5),
          ),
          hintStyle: TextStyle(color: c.dimmed),
          labelStyle: TextStyle(color: c.muted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: c.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: c.accent),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: c.bg,
          foregroundColor: c.text,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: c.card,
          selectedItemColor: c.accent,
          unselectedItemColor: c.dimmed,
          type: BottomNavigationBarType.fixed,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.accent : c.dimmed,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.accentGlow : c.border,
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: c.card,
          titleTextStyle: TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.w700),
          contentTextStyle: TextStyle(color: c.muted, fontSize: 14),
        ),
      );
}
