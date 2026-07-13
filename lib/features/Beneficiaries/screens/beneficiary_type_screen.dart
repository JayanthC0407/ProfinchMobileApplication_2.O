import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'add_beneficiary_screen.dart';

class BeneficiaryTypeScreen extends StatelessWidget {
  const BeneficiaryTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const types = [
      {
        'type': 'PBI',
        'title': 'ProFinch Bank',
        'subtitle': 'Transfer to ProFinch account holders',
        'icon': Icons.account_balance_outlined,
        'color': 0xFF2563B0,
        'bg': 0xFFDBEAFE,
      },
      {
        'type': 'LOCAL',
        'title': 'Local',
        'subtitle': 'NEFT / IMPS / RTGS transfers',
        'icon': Icons.location_city_outlined,
        'color': 0xFF0D9488,
        'bg': 0xFFCCFBF1,
      },
      {
        'type': 'INTERNATIONAL',
        'title': 'International',
        'subtitle': 'SWIFT / IBAN international transfers',
        'icon': Icons.public_outlined,
        'color': 0xFFB45309,
        'bg': 0xFFFEF3C7,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
             width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.blueButton],
              ),
              
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.light),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Text(
                      "Add Beneficiary",
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: RT.fs(context, 24),
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Text(
                      "Choose the type of beneficiary",
                      style: TextStyle(
                          color: AppColors.light.withValues(alpha: 0.65), fontSize: AppFontSize.body(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Type cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: types.map((t) {
                final color = Color(t['color'] as int);
                final bg = Color(t['bg'] as int);
                final icon = t['icon'] as IconData;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddBeneficiaryScreen(
                          beneficiaryType: t['type'] as String),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.light,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.surface),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(icon, color: color, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['title'] as String,
                                style: TextStyle(
                                  fontSize: AppFontSize.medium(context),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                t['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: AppFontSize.small(context),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: color),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}