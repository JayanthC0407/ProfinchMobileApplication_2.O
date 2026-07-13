import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

/// Named text styles that combine AppFontSize + AppColors + fontWeight.
///
/// Usage:
///   Text('Hello', style: AppTextStyles.heading(context))
///
/// All methods accept an optional [color] override so you can tint a
/// style without rebuilding from scratch:
///   Text('Hi', style: AppTextStyles.body(context, color: Colors.white))
class AppTextStyles {
  AppTextStyles._();

  // ── Dark-background styles (on gradients / images) ─────────────

  /// 28 sp · bold · white  — screen hero titles on dark bg
  static TextStyle whiteHeading(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.xxl(ctx),
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.light,
        letterSpacing: -0.5,
      );

  /// 18 sp · semibold · white — section titles on dark bg
  static TextStyle whiteTitle(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.large(ctx),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.light,
      );

  /// 14 sp · regular · white — body copy on dark bg
  static TextStyle whiteBody(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.body(ctx),
        color: color ?? AppColors.light,
      );

  /// 12 sp · regular · white70 — captions on dark bg
  static TextStyle whiteCaption(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.small(ctx),
        color: color ?? AppColors.light.withValues(alpha: 0.7),
      );

  // ── Light-background styles (on white / surface) ───────────────

  /// 28 sp · bold · textPrimary — page-level headings
  static TextStyle heading(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.xxl(ctx),
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  /// 22 sp · semibold · textPrimary — card headings / amounts
  static TextStyle titleLarge(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.xl(ctx),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  /// 18 sp · semibold · textPrimary — section titles
  static TextStyle title(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.large(ctx),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  /// 16 sp · medium · textPrimary — prominent labels
  static TextStyle label(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.medium(ctx),
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textPrimary,
      );

  /// 16 sp · semibold · textPrimary — bold labels / button text
  static TextStyle labelBold(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.medium(ctx),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  /// 14 sp · regular · textPrimary — standard body copy
  static TextStyle body(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.body(ctx),
        color: color ?? AppColors.textPrimary,
      );

  /// 14 sp · semibold · textPrimary — emphasized body copy
  static TextStyle bodyBold(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.body(ctx),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  /// 14 sp · regular · textSecondary — secondary / muted body
  static TextStyle bodySecondary(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.body(ctx),
        color: color ?? AppColors.textSecondary,
      );

  /// 12 sp · regular · textSecondary — small supporting text
  static TextStyle small(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.small(ctx),
        color: color ?? AppColors.textSecondary,
      );

  /// 12 sp · medium · textSecondary — small bold labels (tags, chips)
  static TextStyle smallBold(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.small(ctx),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textSecondary,
      );

  /// 10 sp · regular · textMuted — timestamps, fine print
  static TextStyle caption(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.xs(ctx),
        color: color ?? AppColors.textMuted,
      );

  /// 10 sp · medium · textMuted — slightly-emphasized captions
  static TextStyle captionBold(BuildContext ctx, {Color? color}) => TextStyle(
        fontSize: AppFontSize.xs(ctx),
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textMuted,
      );
}