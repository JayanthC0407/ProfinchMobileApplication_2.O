import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────
  static const Color primary      = Color.fromARGB(255, 26, 92, 224);   // #1A5CE0
  static const Color primaryDark  = Color.fromARGB(255, 15, 2, 87);     // #0F0257
  static const Color accent       = Color.fromARGB(255, 72, 131, 248);  // #4883F8
  static const Color light        = Colors.white;
  static const Color lightBlue    = Color.fromARGB(255, 204, 213, 231); // #CCD5E7

  // ── Text ───────────────────────────────────────────────────────
  /// Primary text — used 61× across the app (was Color(0xFF1A1A2E))
  static const Color textPrimary   = Color(0xFF1A1A2E);
  /// Secondary text — medium-emphasis labels (was Color(0xFF6B7280))
  static const Color textSecondary = Color(0xFF6B7280);
  /// Muted / hint text (was Color(0xFF9CA3AF))
  static const Color textMuted     = Color(0xFF9CA3AF);
  /// Dark variant — near-black headings (was Color(0xFF111827))
  static const Color textDark      = Colors.black;

  // ── Background / Surface ───────────────────────────────────────
  /// Page scaffold background (was Color(0xFFF5F6FA) / 0xFFF5F7FA)
  static const Color background    = Color(0xFFF5F7FA);
  /// Card / surface background (was Color(0xFFE5E7EB))
  static const Color surface       = Color(0xFFE5E7EB);
  /// Lightest surface — subtle section bg (was Color(0xFFF3F4F6))
  static const Color surfaceLight  = Color(0xFFF3F4F6);

  // ── Semantic — Success ─────────────────────────────────────────
  static const Color successDark   = Color(0xFF15803D);
  static const Color success       = Color(0xFF059669);
  static const Color successLight  = Color(0xFFD1FAE5);

  // ── Semantic — Error ───────────────────────────────────────────
  static const Color errorDark     = Color(0xFFB71C1C);
  static const Color error         = Color(0xFFEF4444);
  static const Color errorLight    = Color(0xFFFFEBEE);

  // ── Semantic — Warning ─────────────────────────────────────────
  static const Color warningDark   = Color(0xFFB45309);
  static const Color warning       = Color(0xFFD97706);
  static const Color warningLight  = Color(0xFFFEF3C7);

  // ── Blues (gradient & UI accents) ──────────────────────────────
  /// Deep navy — AppBar gradients, card headers (was Color(0xFF0A3D62))
  static const Color navyDark      = Color(0xFF0A3D62);
  /// Mid-navy — gradient pair (was Color(0xFF1A3A6B))
  static const Color navy          = Color(0xFF1A3A6B);
  /// Button / highlight blue (was Color(0xFF2563B0))
  static const Color blueButton    = Color(0xFF2563B0);
  /// Gradient end blue (was Color(0xFF1A5FA5))
  static const Color blueGradEnd   = Color(0xFF1A5FA5);

  // ── Neutral greys ──────────────────────────────────────────────
  static const Color grey200       = Color(0xFFE5E7EB);
  static const Color grey300       = Color(0xFFD1D5DB);
  static const Color grey400       = Color(0xFF9CA3AF);
  static const Color grey500       = Color.fromARGB(255, 60, 64, 71);
  static const Color grey700       = Color(0xFF555555);

  // ── Icon backgrounds ──────────────────────────────────────────
  /// Light blue tint used behind CircleAvatar icons (was Color(0xffEEF3FF))
  static const Color iconBackground = Color(0xFFEEF3FF);
}