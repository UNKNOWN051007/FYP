import 'package:flutter/material.dart';

/// ThemeExtension that holds all WageWise palette tokens.
class WageColors extends ThemeExtension<WageColors> {
  final Color bg;
  final Color card;
  final Color cardAlt;
  final Color border;
  final Color accent;
  final Color accentAlt;
  final Color accentGlow;
  final Color teal;
  final Color green;
  final Color amber;
  final Color red;
  final Color purple;
  final Color text;
  final Color muted;
  final Color dimmed;
  final List<Color> gradientPrimary;
  final List<Color> gradientSecondary;
  final List<Color> gradientAmber;

  const WageColors({
    required this.bg,
    required this.card,
    required this.cardAlt,
    required this.border,
    required this.accent,
    required this.accentAlt,
    required this.accentGlow,
    required this.teal,
    required this.green,
    required this.amber,
    required this.red,
    required this.purple,
    required this.text,
    required this.muted,
    required this.dimmed,
    required this.gradientPrimary,
    required this.gradientSecondary,
    required this.gradientAmber,
  });

  @override
  WageColors copyWith({
    Color? bg,
    Color? card,
    Color? cardAlt,
    Color? border,
    Color? accent,
    Color? accentAlt,
    Color? accentGlow,
    Color? teal,
    Color? green,
    Color? amber,
    Color? red,
    Color? purple,
    Color? text,
    Color? muted,
    Color? dimmed,
    List<Color>? gradientPrimary,
    List<Color>? gradientSecondary,
    List<Color>? gradientAmber,
  }) =>
      WageColors(
        bg: bg ?? this.bg,
        card: card ?? this.card,
        cardAlt: cardAlt ?? this.cardAlt,
        border: border ?? this.border,
        accent: accent ?? this.accent,
        accentAlt: accentAlt ?? this.accentAlt,
        accentGlow: accentGlow ?? this.accentGlow,
        teal: teal ?? this.teal,
        green: green ?? this.green,
        amber: amber ?? this.amber,
        red: red ?? this.red,
        purple: purple ?? this.purple,
        text: text ?? this.text,
        muted: muted ?? this.muted,
        dimmed: dimmed ?? this.dimmed,
        gradientPrimary: gradientPrimary ?? this.gradientPrimary,
        gradientSecondary: gradientSecondary ?? this.gradientSecondary,
        gradientAmber: gradientAmber ?? this.gradientAmber,
      );

  @override
  WageColors lerp(WageColors? other, double t) {
    if (other == null) return this;
    return WageColors(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentAlt: Color.lerp(accentAlt, other.accentAlt, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      green: Color.lerp(green, other.green, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      red: Color.lerp(red, other.red, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      dimmed: Color.lerp(dimmed, other.dimmed, t)!,
      gradientPrimary: [
        Color.lerp(gradientPrimary[0], other.gradientPrimary[0], t)!,
        Color.lerp(gradientPrimary[1], other.gradientPrimary[1], t)!,
      ],
      gradientSecondary: [
        Color.lerp(gradientSecondary[0], other.gradientSecondary[0], t)!,
        Color.lerp(gradientSecondary[1], other.gradientSecondary[1], t)!,
      ],
      gradientAmber: [
        Color.lerp(gradientAmber[0], other.gradientAmber[0], t)!,
        Color.lerp(gradientAmber[1], other.gradientAmber[1], t)!,
      ],
    );
  }

  // ── Preset instances ─────────────────────────────────────────────────────

  static const WageColors darkNavy = WageColors(
    bg: Color(0xFF0E1B2E),
    card: Color(0xFF162035),
    cardAlt: Color(0xFF1A2640),
    border: Color(0x1AFFFFFF),
    accent: Color(0xFFFF921C),
    accentAlt: Color(0xFFECA427),
    accentGlow: Color(0x40FF921C),
    teal: Color(0xFF14B8A6),
    green: Color(0xFF22C55E),
    amber: Color(0xFFECA427),
    red: Color(0xFFEF4444),
    purple: Color(0xFF8B5CF6),
    text: Color(0xFFF0F4FF),
    muted: Color(0xFF8A9BBE),
    dimmed: Color(0xFF4A5A7A),
    gradientPrimary: [Color(0xFFFF921C), Color(0xFFECA427)],
    gradientSecondary: [Color(0xFFECA427), Color(0xFFFF6B35)],
    gradientAmber: [Color(0xFFFF921C), Color(0xFFEF4444)],
  );

  static const WageColors lightDay = WageColors(
    bg: Color(0xFFF5F7FA),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFEEF1F6),
    border: Color(0x18000000),
    accent: Color(0xFFFF921C),
    accentAlt: Color(0xFFECA427),
    accentGlow: Color(0x30FF921C),
    teal: Color(0xFF0D9488),
    green: Color(0xFF16A34A),
    amber: Color(0xFFD97706),
    red: Color(0xFFDC2626),
    purple: Color(0xFF7C3AED),
    text: Color(0xFF1A1F2E),
    muted: Color(0xFF6B7280),
    dimmed: Color(0xFF9CA3AF),
    gradientPrimary: [Color(0xFFFF921C), Color(0xFFECA427)],
    gradientSecondary: [Color(0xFFECA427), Color(0xFFFF6B35)],
    gradientAmber: [Color(0xFFFF921C), Color(0xFFEF4444)],
  );

  static const WageColors midnight = WageColors(
    bg: Color(0xFF050505),
    card: Color(0xFF0F0F0F),
    cardAlt: Color(0xFF141414),
    border: Color(0x18FFFFFF),
    accent: Color(0xFFFF921C),
    accentAlt: Color(0xFFECA427),
    accentGlow: Color(0x40FF921C),
    teal: Color(0xFF14B8A6),
    green: Color(0xFF22C55E),
    amber: Color(0xFFECA427),
    red: Color(0xFFEF4444),
    purple: Color(0xFF8B5CF6),
    text: Color(0xFFF0F4FF),
    muted: Color(0xFF8A9BBE),
    dimmed: Color(0xFF4A5A7A),
    gradientPrimary: [Color(0xFFFF921C), Color(0xFFECA427)],
    gradientSecondary: [Color(0xFFECA427), Color(0xFFFF6B35)],
    gradientAmber: [Color(0xFFFF921C), Color(0xFFEF4444)],
  );

  static const WageColors sunset = WageColors(
    bg: Color(0xFF1C0F05),
    card: Color(0xFF2A1810),
    cardAlt: Color(0xFF3A2218),
    border: Color(0x18FF921C),
    accent: Color(0xFFFF921C),
    accentAlt: Color(0xFFFF6B35),
    accentGlow: Color(0x40FF921C),
    teal: Color(0xFF14B8A6),
    green: Color(0xFF22C55E),
    amber: Color(0xFFECA427),
    red: Color(0xFFEF4444),
    purple: Color(0xFF8B5CF6),
    text: Color(0xFFFFF3E0),
    muted: Color(0xFFC49A6C),
    dimmed: Color(0xFF7A5A3A),
    gradientPrimary: [Color(0xFFFF921C), Color(0xFFFF6B35)],
    gradientSecondary: [Color(0xFFECA427), Color(0xFFFF6B35)],
    gradientAmber: [Color(0xFFFF921C), Color(0xFFEF4444)],
  );

  static const WageColors ocean = WageColors(
    bg: Color(0xFF051520),
    card: Color(0xFF0A2030),
    cardAlt: Color(0xFF0D2840),
    border: Color(0x1814B8A6),
    accent: Color(0xFF14B8A6),
    accentAlt: Color(0xFF06B6D4),
    accentGlow: Color(0x4014B8A6),
    teal: Color(0xFF14B8A6),
    green: Color(0xFF22C55E),
    amber: Color(0xFFECA427),
    red: Color(0xFFEF4444),
    purple: Color(0xFF8B5CF6),
    text: Color(0xFFF0F4FF),
    muted: Color(0xFF8A9BBE),
    dimmed: Color(0xFF4A5A7A),
    gradientPrimary: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
    gradientSecondary: [Color(0xFF06B6D4), Color(0xFF14B8A6)],
    gradientAmber: [Color(0xFF14B8A6), Color(0xFFEF4444)],
  );
}

/// Convenience extension so any widget can write `context.wc`.
extension WageColorsX on BuildContext {
  WageColors get wc => Theme.of(this).extension<WageColors>()!;
}

// ── Static AppColors shim — keeps old code that references AppColors.xxx compiling ──

/// Static fallback using the Dark Navy palette.
/// New code should use `context.wc` instead.
class AppColors {
  static const WageColors _dark = WageColors.darkNavy;

  static Color get bg => _dark.bg;
  static Color get card => _dark.card;
  static Color get cardAlt => _dark.cardAlt;
  static Color get border => _dark.border;
  static Color get accent => _dark.accent;
  static Color get accentAlt => _dark.accentAlt;
  static Color get accentGlow => _dark.accentGlow;
  static Color get teal => _dark.teal;
  static Color get green => _dark.green;
  static Color get amber => _dark.amber;
  static Color get red => _dark.red;
  static Color get purple => _dark.purple;
  static Color get text => _dark.text;
  static Color get muted => _dark.muted;
  static Color get dimmed => _dark.dimmed;

  // Gradient aliases used by older code
  static List<Color> get gradientBlue => _dark.gradientPrimary;
  static List<Color> get gradientTeal => _dark.gradientSecondary;
  static List<Color> get gradientAmber => _dark.gradientAmber;
  static List<Color> get gradientOrange => _dark.gradientPrimary;
}
