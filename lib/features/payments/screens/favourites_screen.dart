import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/beneficiary_model.dart';
import 'package:profinch_mobile_application/data/models/payment_model.dart';
import 'package:profinch_mobile_application/features/Beneficiaries/provider/beneficiary_provider.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/payments/provider/payment_provider.dart';
import 'package:profinch_mobile_application/features/transfers/screens/pbi_transfer_screen.dart';
import 'package:profinch_mobile_application/features/transfers/screens/local_transfer_screen.dart';
import 'package:profinch_mobile_application/features/transfers/screens/international_transfer_screen.dart';
import 'package:provider/provider.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final beneficiaryProvider = Provider.of<BeneficiaryProvider>(context);

    final favourites  = paymentProvider.favourites(user.id);
    final frequent    = paymentProvider.frequentlyUsed(user.id);
    final beneficiaries = beneficiaryProvider.getBeneficiariesByUserId(user.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.light,
        title: Text('Favourites & Frequent',
            style: AppTextStyles.whiteTitle(context)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Favourites ─────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text('Favourites', style: AppTextStyles.title(context)),
              ],
            ),
            const SizedBox(height: 12),

            if (favourites.isEmpty)
              _EmptyState(
                icon: Icons.star_border_rounded,
                message:
                    'No favourites yet. Star a payment from your history to see it here.',
              )
            else
              ...favourites.map((p) => _PaymentCard(
                    payment: p,
                    beneficiaryProvider: beneficiaryProvider,
                    onTransfer: () => _navigateToTransfer(
                        context, p, beneficiaryProvider),
                    onToggleFavourite: () =>
                        paymentProvider.toggleFavourite(p.id),
                  )),

            const SizedBox(height: 24),

            // ── Frequently Used ─────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.bolt_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Frequently Used', style: AppTextStyles.title(context)),
              ],
            ),
            const SizedBox(height: 12),

            if (frequent.isEmpty)
              _EmptyState(
                icon: Icons.history_rounded,
                message:
                    'Your most-used transfers will appear here automatically.',
              )
            else
              ...frequent.map((p) => _PaymentCard(
                    payment: p,
                    beneficiaryProvider: beneficiaryProvider,
                    onTransfer: () => _navigateToTransfer(
                        context, p, beneficiaryProvider),
                    onToggleFavourite: () =>
                        paymentProvider.toggleFavourite(p.id),
                    showUsageCount: true,
                  )),

            const SizedBox(height: 24),

            // ── Beneficiary quick launch ────────────────────────────
            Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    color: AppColors.blueButton, size: 20),
                const SizedBox(width: 8),
                Text('All Beneficiaries', style: AppTextStyles.title(context)),
              ],
            ),
            const SizedBox(height: 12),

            if (beneficiaries.isEmpty)
              _EmptyState(
                icon: Icons.people_outline,
                message: 'No beneficiaries added yet.',
              )
            else
              _BeneficiaryGrid(
                beneficiaries: beneficiaries,
                onTap: (b) => _navigateToBeneficiaryTransfer(context, b),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToTransfer(BuildContext context, PaymentModel p,
      BeneficiaryProvider provider) {
    if (p.beneficiaryId == null) return;
    final b = provider.getById(p.beneficiaryId!);
    if (b == null) return;
    _navigateToBeneficiaryTransfer(context, b);
  }

  void _navigateToBeneficiaryTransfer(
      BuildContext context, BeneficiaryModel b) {
    if (!b.isTransferAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${b.nickname} is still in cooling period. Please wait.'),
        backgroundColor: AppColors.warningDark,
      ));
      return;
    }
    Widget screen;
    switch (b.beneficiaryType) {
      case 'PBI':
        screen = PbiTransferScreen(beneficiary: b);
        break;
      case 'LOCAL':
        screen = LocalTransferScreen(beneficiary: b);
        break;
      default:
        screen = InternationalTransferScreen(beneficiary: b);
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final BeneficiaryProvider beneficiaryProvider;
  final VoidCallback onTransfer;
  final VoidCallback onToggleFavourite;
  final bool showUsageCount;

  const _PaymentCard({
    required this.payment,
    required this.beneficiaryProvider,
    required this.onTransfer,
    required this.onToggleFavourite,
    this.showUsageCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              payment.receiverName[0].toUpperCase(),
              style: AppTextStyles.title(context, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.receiverName,
                    style: AppTextStyles.bodyBold(context)),
                const SizedBox(height: 2),
                Text(
                  '${payment.transferMode}  •  '
                  '₹ ${payment.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.small(context),
                ),
                if (showUsageCount && payment.useCount > 0) ...[
                  const SizedBox(height: 2),
                  Text('${payment.useCount} transfers',
                      style: AppTextStyles.caption(context,
                          color: AppColors.primary)),
                ],
              ],
            ),
          ),

          // Star toggle
          GestureDetector(
            onTap: onToggleFavourite,
            child: Icon(
              payment.isFavourite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: payment.isFavourite
                  ? AppColors.warning
                  : AppColors.grey400,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),

          // Transfer button
          GestureDetector(
            onTap: onTransfer,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Pay',
                  style: AppTextStyles.smallBold(context,
                      color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.grey400),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary(context)),
          ),
        ],
      ),
    );
  }
}

class _BeneficiaryGrid extends StatelessWidget {
  final List<BeneficiaryModel> beneficiaries;
  final void Function(BeneficiaryModel) onTap;

  const _BeneficiaryGrid({
    required this.beneficiaries,
    required this.onTap,
  });

  Color _typeColor(String type) {
    switch (type) {
      case 'PBI':           return AppColors.blueButton;
      case 'LOCAL':         return AppColors.success;
      case 'INTERNATIONAL': return AppColors.warningDark;
      default:              return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: beneficiaries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, i) {
        final b = beneficiaries[i];
        final cooling = !b.isTransferAllowed;
        return GestureDetector(
          onTap: () => onTap(b),
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cooling
                    ? AppColors.warningLight
                    : _typeColor(b.beneficiaryType)
                        .withValues(alpha: 0.12),
                child: cooling
                    ? Icon(Icons.lock_clock_outlined,
                        color: AppColors.warning, size: 20)
                    : Text(
                        b.nickname[0].toUpperCase(),
                        style: AppTextStyles.title(context,
                            color: _typeColor(b.beneficiaryType)),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                b.nickname.split(' ').first,
                style: AppTextStyles.small(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}