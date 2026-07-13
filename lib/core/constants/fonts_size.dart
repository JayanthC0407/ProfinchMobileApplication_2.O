import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';

class AppFontSize {
  AppFontSize._();

  // ── Semantic scale ─────────────────────────────────────────────
  static double xs(BuildContext ctx)    => RT.fs(ctx, 10);
  static double small(BuildContext ctx) => RT.fs(ctx, 12);
  static double body(BuildContext ctx)  => RT.fs(ctx, 14);
  static double medium(BuildContext ctx)=> RT.fs(ctx, 16);
  static double large(BuildContext ctx) => RT.fs(ctx, 18);
  static double xl(BuildContext ctx)    => RT.fs(ctx, 22);
  static double xxl(BuildContext ctx)   => RT.fs(ctx, 28);


  //  import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
  // 10  → AppFontSize.xs(context)
  // 12  → AppFontSize.small(context)
  // 14  → AppFontSize.body(context)
  // 16  → AppFontSize.medium(context)
  // 18  → AppFontSize.large(context)
  // 22  → AppFontSize.xl(context)
  // 28  → AppFontSize.xxl(context)


// TODO: Phase 3 — Medium screens (14–29 usages)
// Work through these one file at a time:
// dashboard/       → 14 usages   ← start here, most visible
// Transactions/    → 22 usages
// loans/           → 27 usages
// Beneficiaries/   → 29 usages

// TODO: Phase 4 — Larger features (34–45 usages)
// auth/            → 24 usages
// calculators/     → 23 usages
// cards/           → 38 usages
// bills/           → 37 usages
// upi/             → 34 usages
// wallet/          → 45 usages

// TODO: Phase 5 — Biggest last
// rewards/         → 40 usages
// term_deposit/    → 62 usages
// transfers/       → 71 usages   ← tackle last
}