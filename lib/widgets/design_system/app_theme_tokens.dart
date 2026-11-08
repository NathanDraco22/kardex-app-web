import 'package:flutter/material.dart';

/// Tokens de diseño globales para Kardex App (Bento UI / Modern SaaS).
class AppThemeTokens {
  AppThemeTokens._();

  // Radios de borde
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // Paleta Semántica
  static const Color success = Color(0xFF10B981); // Esmeralda
  static const Color warning = Color(0xFFF59E0B); // Ámbar
  static const Color danger = Color(0xFFEF4444);  // Rojo / Carmesí
  static const Color info = Color(0xFF0EA5E9);    // Azul cielo
  static const Color purple = Color(0xFF8B5CF6);  // Púrpura
  static const Color indigo = Color(0xFF6366F1);  // Índigo
  static const Color teal = Color(0xFF14B8A6);    // Teal
  static const Color neutral = Color(0xFF64748B); // Slate

  // Superficies
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color cardBg = Colors.white;

  // Sombras Bento
  static List<BoxShadow> subtleCardShadow({Color? accent}) {
    return [
      BoxShadow(
        color: accent != null
            ? accent.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.025),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> hoverCardShadow({Color? accent}) {
    return [
      BoxShadow(
        color: accent != null
            ? accent.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> dialogShadow() {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 32,
        offset: const Offset(0, 12),
      ),
    ];
  }
}
