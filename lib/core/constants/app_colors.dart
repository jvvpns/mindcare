import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary — Vibrant Sky Blue ───────────────────────────────────────────
  static const Color primary          = Color(0xFF4FC3F7);
  static const Color primaryLight     = Color(0xFFE1F5FE);
  static const Color primaryDark      = Color(0xFF0288D1);
  static const Color primaryText      = Color(0xFF01579B);

  // ── Secondary — Deep Teal/Mint ──────────────────────────────────────────
  static const Color secondary        = Color(0xFF4DB6AC);
  static const Color secondaryLight   = Color(0xFFE0F2F1);
  static const Color secondaryDark    = Color(0xFF00796B);
  static const Color secondaryText    = Color(0xFF004D40);

  // ── Accent — Royal Lavender ──────────────────────────────────────────────
  static const Color accent           = Color(0xFF9575CD);
  static const Color accentLight      = Color(0xFFF3E5F5);
  static const Color accentDark       = Color(0xFF5E35B1);
  static const Color accentText       = Color(0xFF311B92);

  // ── Neutral Background — Soft Slate ──────────────────────────────────────
  static const Color background       = Color(0xFFF9FBFF);
  static const Color surface          = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFE1E8F0);

  // ── Text — Deep Onyx ──────────────────────────────────────────────────────
  static const Color textPrimary      = Color(0xFF1A1C1E);
  static const Color textSecondary    = Color(0xFF5F6368);
  static const Color textTertiary     = Color(0xFF8E9196);
  static const Color textHint         = Color(0xFFBDC1C6);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success          = Color(0xFF66BB6A);
  static const Color successLight     = Color(0xFFE8F5E9);
  static const Color warning          = Color(0xFFFFB74D);
  static const Color warningLight     = Color(0xFFFFF3E0);
  static const Color error            = Color(0xFFEF9A9A);
  static const Color errorLight       = Color(0xFFFCEBEB);
  static const Color info             = Color(0xFF4FC3F7);
  static const Color infoLight        = Color(0xFFE1F5FE);

  // ── Crisis / Emergency ────────────────────────────────────────────────────
  static const Color crisis           = Color(0xFFF06292);
  static const Color crisisLight      = Color(0xFFFCE4EC);
  static const Color crisisText       = Color(0xFF880E4F);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color borderLight      = Color(0xFFE1E3E8);
  static const Color borderMedium     = Color(0xFFD1D3D8);
  static const Color borderDark       = Color(0xFFB1B3B8);

  // ── Mood Colors (Project Palette) ────────────────────────────────────────
  static const Color moodHappy        = Color(0xFF4FC3F7);
  static const Color moodSad          = Color(0xFFB39DDB);
  static const Color moodCalm         = Color(0xFF4DB6AC);
  static const Color moodExcited      = Color(0xFFFFD54F);
  static const Color moodConcerned    = Color(0xFFFFAB91);
  static const Color moodNeutral      = Color(0xFF8E9196);

  // ── Chart Colors ─────────────────────────────────────────────────────────
  static const Color chartMood        = Color(0xFF4FC3F7);
  static const Color chartStress      = Color(0xFFFFAB91);
  static const Color chartBurnout     = Color(0xFFF06292);

  // ── Emotion to UI Color Mapping (Mesh Gradient Pairs) ───────────────────
  static Map<String, List<Color>> get emotionToColors => {
    'default':   [const Color(0xFFF9F8F6), const Color(0xFFE1E8F0)], // Neutral
    'happy':     [const Color(0xFFE1F5FE), const Color(0xFF4FC3F7)], // Sky Blue
    'sad':       [const Color(0xFFF3E5F5), const Color(0xFFB39DDB)], // Muted Lavender
    'excited':   [const Color(0xFFFFF9C4), const Color(0xFFFFD54F)], // Electric Gold
    'concerned': [const Color(0xFFFFF3E0), const Color(0xFFFFAB91)], // Soft Coral/Peach
    'calm':      [const Color(0xFFE0F2F1), const Color(0xFF4DB6AC)], // Deep Teal/Mint
    'surprised': [const Color(0xFFFCE4EC), const Color(0xFFF06292)], // Bright Pink
  };
}