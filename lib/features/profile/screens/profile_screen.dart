import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import 'package:profinch_mobile_application/data/dummy/dummy_accounts.dart';
import 'package:provider/provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_tile.dart';
import '../widgets/settings_tile.dart';
import 'edit_profile_screen.dart';
import 'security_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';
import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';

// ── NEW (1) ── add these two imports ─────────────────────────────
import 'package:profinch_mobile_application/core/l10n/app_localizations.dart';
import 'package:profinch_mobile_application/features/profile/provider/language_provider.dart';
// ─────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── REMOVED (2) ── String _selectedLanguage = 'English (India)';
  // The selected language now lives in LanguageProvider, not local State.

  @override
  Widget build(BuildContext context) {
    // ── NEW ── one-liner lookup
    final t = AppLocalizations.of(context);

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;

    final primaryAccount = DummyAccounts.allAccounts.firstWhere(
      (a) => a.id == user.primaryAccountId,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.lightBlue,

        appBar: AppBar(
          backgroundColor: AppColors.lightBlue,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            // ── CHANGED ── was: 'Profile'
            t.profile_title,
            style: TextStyle(
              color: Colors.black,
              fontSize: AppFontSize.large(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2640),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2E3A57), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFF4A90D9),
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      // ── CHANGED ── was: 'Edit'
                      t.profile_editBtn,
                      style: TextStyle(
                        color: const Color(0xFF4A90D9),
                        fontSize: AppFontSize.small(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile header ─────────────────────────────────
              ProfileHeader(
                username: user.username,
                email: user.email,
                isKycVerified: user.isKycVerified,
                accountType: primaryAccount.accountType,
              ),

              const SizedBox(height: 24),

              // ── Personal information ───────────────────────────
              // ── CHANGED ── was: 'PERSONAL INFORMATION'
              _sectionLabel(t.profile_sectionPersonal, context),
              const SizedBox(height: 10),

              ProfileInfoTile(
                // ── CHANGED ── was: 'PHONE NUMBER'
                title: t.profile_phone,
                value: user.phoneNumber,
                icon: Icons.phone_rounded,
              ),

              ProfileInfoTile(
                // ── CHANGED ── was: 'PAN NUMBER'
                title: t.profile_pan,
                value: user.panNumber,
                icon: Icons.badge_rounded,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CD964).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF4CD964).withOpacity(0.35),
                    ),
                  ),
                  child: Text(
                    // ── CHANGED ── was: 'Verified'
                    t.profile_verified,
                    style: const TextStyle(
                      color: Color(0xFF4CD964),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              ProfileInfoTile(
                // ── CHANGED ── was: 'PRIMARY ACCOUNT'
                title: t.profile_primaryAccount,
                value:
                    '${primaryAccount.accountType}  •  ••••${primaryAccount.accountNumber.substring(primaryAccount.accountNumber.length - 4)}',
                icon: Icons.account_balance_rounded,
              ),

              ProfileInfoTile(
                // ── CHANGED ── was: 'MEMBER SINCE'
                title: t.profile_memberSince,
                value: _formatDate(user.createdAt),
                icon: Icons.calendar_today_rounded,
              ),

              const SizedBox(height: 24),

              // ── Account & Security ────────────────────────────
              // ── CHANGED ── was: 'ACCOUNT & SECURITY'
              _sectionLabel(t.profile_sectionSecurity, context),
              const SizedBox(height: 10),

              SettingsTile(
                // ── CHANGED ── was: 'Security Settings'
                title: t.profile_security,
                // ── CHANGED ── was: 'PIN, biometrics, 2FA'
                subtitle: t.profile_securitySub,
                icon: Icons.shield_rounded,
                iconColor: const Color(0xFF4A90D9),
                iconBgColor: const Color(0xFF4A90D9).withOpacity(0.12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SecuritySettingsScreen(),
                  ),
                ),
              ),

              SettingsTile(
                // ── CHANGED ── was: 'Linked Devices'
                title: t.profile_linkedDevices,
                // ── CHANGED ── was: '2 devices active'
                subtitle: t.profile_linkedDevicesSub,
                icon: Icons.devices_rounded,
                iconColor: const Color(0xFF9B59B6),
                iconBgColor: const Color(0xFF9B59B6).withOpacity(0.12),
                onTap: () => _showLinkedDevices(context),
              ),

              SettingsTile(
                // ── CHANGED ── was: 'Login Activity'
                title: t.profile_loginActivity,
                // ── CHANGED ── was: 'Last login: Today, 9:41 AM'
                subtitle: t.profile_loginActivitySub,
                icon: Icons.history_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFF59E0B).withOpacity(0.12),
                onTap: () => _showLoginActivity(context),
              ),

              const SizedBox(height: 24),

              // ── Preferences ───────────────────────────────────
              // ── CHANGED ── was: 'PREFERENCES'
              _sectionLabel(t.profile_sectionPrefs, context),
              const SizedBox(height: 10),

              SettingsTile(
                // ── CHANGED ── was: 'Notifications'
                title: t.profile_notifications,
                // ── CHANGED ── was: 'Alerts, SMS, email'
                subtitle: t.profile_notifSub,
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFF10B981).withOpacity(0.12),
                onTap: () => _showNotificationPrefs(context),
                badge: _toggleBadge(true),
                showArrow: false,
              ),

              SettingsTile(
                // ── CHANGED ── was: 'Language'
                title: t.profile_language,
                // ── CHANGED (3) ── was: _selectedLanguage
                // Now reads live from LanguageProvider so the subtitle
                // updates immediately when the user picks a language.
                subtitle: context
                    .watch<LanguageProvider>()
                    .selectedLanguageName,
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF4A90D9),
                iconBgColor: const Color(0xFF4A90D9).withOpacity(0.12),
                onTap: () => _showLanguagePicker(context),
              ),

              // SettingsTile(
              //   // ── CHANGED ── was: 'Statement Preferences'
              //   title: t.profile_statement,
              //   // ── CHANGED ── was: 'Digital — delivered to email'
              //   subtitle: t.profile_statementSub,
              //   icon: Icons.receipt_long_rounded,
              //   iconColor: const Color(0xFF0EA5E9),
              //   iconBgColor: const Color(0xFF0EA5E9).withOpacity(0.12),
              //   onTap: () => _showStatementPrefs(context),
              // ),

              const SizedBox(height: 24),

              // ── Support & Legal ───────────────────────────────
              // ── CHANGED ── was: 'SUPPORT & LEGAL'
              _sectionLabel(t.profile_sectionSupport, context),
              const SizedBox(height: 10),

              SettingsTile(
                // ── CHANGED ── was: 'Help & Support'
                title: t.profile_help,
                // ── CHANGED ── was: 'FAQs, live chat, call us'
                subtitle: t.profile_helpSub,
                icon: Icons.headset_mic_rounded,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFF10B981).withOpacity(0.12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                ),
              ),

              SettingsTile(
                // ── CHANGED ── was: 'Privacy Policy'
                title: t.profile_privacy,
                // ── CHANGED ── was: 'Last updated Jan 2025'
                subtitle: t.profile_privacySub,
                icon: Icons.privacy_tip_rounded,
                iconColor: const Color(0xFF4A90D9),
                iconBgColor: const Color(0xFF4A90D9).withOpacity(0.12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),

              SettingsTile(
                // ── CHANGED ── was: 'Terms & Conditions'
                title: t.profile_terms,
                // ── CHANGED ── was: 'User agreement'
                subtitle: t.profile_termsSub,
                icon: Icons.description_rounded,
                iconColor: const Color(0xFF8A9BB5),
                iconBgColor: const Color(0xFF8A9BB5).withOpacity(0.12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(showTerms: true),
                  ),
                ),
              ),

              SettingsTile(
                // ── CHANGED ── was: 'Rate the App'
                title: t.profile_rate,
                // ── CHANGED ── was: 'Share your feedback'
                subtitle: t.profile_rateSub,
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFF59E0B).withOpacity(0.12),
                onTap: () => _showRating(context),
              ),

              const SizedBox(height: 24),

              // ── Logout ────────────────────────────────────────
              SettingsTile(
                // ── CHANGED ── was: 'Log Out'
                title: t.profile_logout,
                icon: Icons.logout_rounded,
                onTap: () => _confirmLogout(context, authProvider),
                isDestructive: true,
                showArrow: false,
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  // ── CHANGED ── was: 'ProFinch v1.0.0  •  Build 100'
                  t.common_appVersion,
                  style: TextStyle(
                    color: const Color(0xFF8A9BB5).withOpacity(0.5),
                    fontSize: AppFontSize.xs(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  Widget _sectionLabel(String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF8A9BB5),
          fontSize: AppFontSize.xs(context),
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _toggleBadge(bool enabled) {
    return Container(
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFF4CD964) : const Color(0xFF2E3A57),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // ── Language picker ─────────────────────────────────────────────
  // The list of names must match the keys in AppLocalizations.nameToLocale.
  void _showLanguagePicker(BuildContext context) {
    final languages = [
      'English (India)',
      'Hindi',
      'Kannada',
      'Tamil',
      'Telugu',
      'Marathi',
    ];

    // Start the sheet's local selection from whatever is already persisted.
    String sheetSelected = context
        .read<LanguageProvider>()
        .selectedLanguageName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setS) => DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Language',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: AppFontSize.large(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // scrollable language list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: languages.length,
                    itemBuilder: (_, i) {
                      final lang = languages[i];
                      final isSelected = lang == sheetSelected;
                      return GestureDetector(
                        onTap: () {
                          // 1. update sheet highlight immediately
                          setS(() => sheetSelected = lang);
                          // 2. ── CHANGED (4) ── write to LanguageProvider
                          //    instead of setState(() => _selectedLanguage = lang)
                          Future.delayed(const Duration(milliseconds: 180), () {
                            context.read<LanguageProvider>().setLanguage(lang);
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4A90D9).withOpacity(0.1)
                                : AppColors.light,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4A90D9).withOpacity(0.4)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                lang,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF4A90D9)
                                      : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF4A90D9),
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── All other action sheets below are unchanged ──────────────────

  void _showLinkedDevices(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Linked Devices',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppFontSize.large(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _deviceTile(
              context,
              name: 'iPhone 14 Pro',
              location: 'Bengaluru, IN',
              lastSeen: 'Active now',
              isCurrent: true,
            ),
            const SizedBox(height: 10),
            _deviceTile(
              context,
              name: 'MacBook Air M2',
              location: 'Bengaluru, IN',
              lastSeen: '2 hours ago',
              isCurrent: false,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935).withOpacity(0.15),
                  foregroundColor: const Color(0xFFE53935),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: const Color(0xFFE53935).withOpacity(0.3),
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Log Out All Other Devices',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceTile(
    BuildContext context, {
    required String name,
    required String location,
    required String lastSeen,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1322),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E3A57)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.devices_rounded,
              color: Color(0xFF9B59B6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CD964).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'This device',
                          style: TextStyle(
                            color: Color(0xFF4CD964),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$location  •  $lastSeen',
                  style: const TextStyle(
                    color: Color(0xFF8A9BB5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrent)
            GestureDetector(
              onTap: () {},
              child: const Icon(
                Icons.remove_circle_outline_rounded,
                color: Color(0xFFE53935),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  void _showLoginActivity(BuildContext context) {
    final sessions = [
      {'time': 'Today, 9:41 AM', 'ip': '192.168.1.10', 'loc': 'Bengaluru, IN'},
      {'time': 'Yesterday, 6:22 PM', 'ip': '10.0.0.5', 'loc': 'Bengaluru, IN'},
      {'time': 'Dec 18, 11:03 AM', 'ip': '172.16.0.2', 'loc': 'Mumbai, IN'},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppFontSize.large(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Recent sign-in sessions',
              style: TextStyle(color: Color(0xFF8A9BB5), fontSize: 12),
            ),
            const SizedBox(height: 20),
            ...sessions.map(
              (s) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1322),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E3A57)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.login_rounded,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['time']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${s['ip']}  •  ${s['loc']}',
                            style: const TextStyle(
                              color: Color(0xFF8A9BB5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationPrefs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2640),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _NotificationPrefsSheet(),
    );
  }

  // void _showStatementPrefs(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: const Color(0xFF1E2640),
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //     ),
  //     builder: (_) => Padding(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Statement Delivery',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: AppFontSize.large(context),
  //               fontWeight: FontWeight.w700,
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           ...['Email (Digital)', 'Post (Physical)', 'Both'].map((opt) {
  //             final isSelected = opt == 'Email (Digital)';
  //             return GestureDetector(
  //               onTap: () => Navigator.pop(context),
  //               child: Container(
  //                 margin: const EdgeInsets.only(bottom: 8),
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 16,
  //                   vertical: 14,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: isSelected
  //                       ? const Color(0xFF4A90D9).withOpacity(0.1)
  //                       : const Color(0xFF0F1322),
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(
  //                     color: isSelected
  //                         ? const Color(0xFF4A90D9).withOpacity(0.4)
  //                         : const Color(0xFF2E3A57),
  //                   ),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Text(
  //                       opt,
  //                       style: TextStyle(
  //                         color: isSelected
  //                             ? const Color(0xFF4A90D9)
  //                             : Colors.white,
  //                         fontSize: 14,
  //                         fontWeight: isSelected
  //                             ? FontWeight.w600
  //                             : FontWeight.w400,
  //                       ),
  //                     ),
  //                     const Spacer(),
  //                     if (isSelected)
  //                       const Icon(
  //                         Icons.check_circle_rounded,
  //                         color: Color(0xFF4A90D9),
  //                         size: 18,
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           }),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showRating(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _RatingSheet(),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE53935),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.common_logOut,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will be signed out of your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8A9BB5),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2E3A57)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      t.common_cancel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      authProvider.logout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                    child: Text(
                      t.common_logOut,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification Prefs Sheet (unchanged) ─────────────────────────
class _NotificationPrefsSheet extends StatefulWidget {
  const _NotificationPrefsSheet();
  @override
  State<_NotificationPrefsSheet> createState() =>
      _NotificationPrefsSheetState();
}

class _NotificationPrefsSheetState extends State<_NotificationPrefsSheet> {
  bool pushEnabled = true;
  bool smsEnabled = true;
  bool emailEnabled = false;
  bool transactionAlerts = true;
  bool promoAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSize.large(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _prefRow(
            'Push Notifications',
            pushEnabled,
            (v) => setState(() => pushEnabled = v),
          ),
          _prefRow(
            'SMS Alerts',
            smsEnabled,
            (v) => setState(() => smsEnabled = v),
          ),
          _prefRow(
            'Email Alerts',
            emailEnabled,
            (v) => setState(() => emailEnabled = v),
          ),
          const Divider(color: Color(0xFF2E3A57), height: 24),
          _prefRow(
            'Transaction Alerts',
            transactionAlerts,
            (v) => setState(() => transactionAlerts = v),
          ),
          _prefRow(
            'Promotional Offers',
            promoAlerts,
            (v) => setState(() => promoAlerts = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90D9),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Save Preferences',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prefRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4A90D9),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ── Rating Sheet (unchanged) ─────────────────────────────────────
class _RatingSheet extends StatefulWidget {
  const _RatingSheet();
  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _stars = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Rate ProFinch',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your feedback helps us improve',
            style: TextStyle(color: Color(0xFF8A9BB5), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _stars = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < _stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          if (_stars > 0)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Submit Rating',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
