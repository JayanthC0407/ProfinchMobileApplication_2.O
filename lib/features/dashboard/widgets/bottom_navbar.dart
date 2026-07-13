import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/rewards/screens/reward_screen.dart';
import 'package:profinch_mobile_application/features/upi/provider/upi_provider.dart';
import 'package:profinch_mobile_application/features/upi/screens/scan_qr_screen.dart';
import 'package:provider/provider.dart';

// ── NEW ──────────────────────────────────────────────────────────
import 'package:profinch_mobile_application/core/l10n/app_localizations.dart';
// ─────────────────────────────────────────────────────────────────

class BottomNavBar extends StatefulWidget {
  final int currentIndex;

  const BottomNavBar({super.key, this.currentIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onTap(int index) {
    if (index == widget.currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.transactions);
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (ctx) => UpiProvider(
                ctx.read<AuthProvider>(),
                ctx.read<AccountProvider>(),
              ),
              child: const ScanQrScreen(),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RewardsScreen(initialTab: 2)),
        );
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── NEW ── fetch translated labels
    final t = AppLocalizations.of(context);
    final smallSize = AppFontSize.small(context);

    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey500,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: smallSize,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(fontSize: smallSize),
      onTap: _onTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          // ── CHANGED ── was: 'Home'
          label: t.nav_home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined),
          activeIcon: const Icon(Icons.receipt_long),
          // ── CHANGED ── was: 'Transactions'
          label: t.nav_transactions,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.qr_code_scanner),
          // ── CHANGED ── was: 'Scan'
          label: t.nav_scan,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.card_giftcard_outlined),
          activeIcon: const Icon(Icons.card_giftcard),
          // ── CHANGED ── was: 'Offers'
          label: t.nav_offers,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          // ── CHANGED ── was: 'Profile'
          label: t.nav_profile,
        ),
      ],
    );
  }
}
