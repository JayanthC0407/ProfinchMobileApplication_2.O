import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'dart:typed_data';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final bool isKycVerified;
  final String accountType;
  final Uint8List? profileImageBytes;
  final String profileImagePath;    

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    this.isKycVerified = false,
    this.accountType = '',
    this.profileImageBytes,  
    this.profileImagePath = '', 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                  ],
                ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2E3A57),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Avatar with gradient ring ──────────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer gradient ring
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90D9), Color(0xFF001F8B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // White gap
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E2640),
                ),
              ),
              // Avatar
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2A3550),
                ),
                child: ClipOval(
                  child: profileImageBytes != null
                      ? Image.memory(profileImageBytes!, fit: BoxFit.cover, width: 76, height: 76)
                      : (profileImagePath.isNotEmpty
                          ? Image.asset(
                              profileImagePath,
                              fit: BoxFit.cover,
                              width: 76,
                              height: 76,
                              errorBuilder: (_, __, ___) => _initials(context),
                            )
                          : _initials(context)),
                ),
              ),
              // KYC badge
              if (isKycVerified)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CD964),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Name ───────────────────────────────────────────────
          Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSize.xl(context),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 4),

          // ── Email ──────────────────────────────────────────────
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSize.small(context),
            ),
          ),

          const SizedBox(height: 16),

          // ── KYC + Account type chips ───────────────────────────
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildChip(
                icon: isKycVerified
                    ? Icons.verified_rounded
                    : Icons.pending_rounded,
                label: isKycVerified ? 'KYC Verified' : 'KYC Pending',
                color: isKycVerified
                    ? const Color(0xFF4CD964)
                    : const Color(0xFFFFA500),
              ),
              if (accountType.isNotEmpty)
                _buildChip(
                  icon: Icons.account_balance_rounded,
                  label: accountType,
                  color: Colors.white,
                ),
              ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
  Widget _initials(BuildContext context) {
  return Center(
    child: Text(
      username
          .trim()
          .split(' ')
          .where((e) => e.isNotEmpty)
          .take(2)
          .map((e) => e[0].toUpperCase())
          .join(),
      style: TextStyle(
        color: const Color(0xFF4A90D9),
        fontSize: AppFontSize.xl(context),
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
}