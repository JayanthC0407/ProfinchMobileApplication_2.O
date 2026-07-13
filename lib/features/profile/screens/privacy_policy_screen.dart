import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool showTerms;
  const PrivacyPolicyScreen({super.key, this.showTerms = false});

  @override
  Widget build(BuildContext context) {
    final title = showTerms ? 'Terms & Conditions' : 'Privacy Policy';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.lightBlue,
        appBar: AppBar(
          backgroundColor: AppColors.lightBlue,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.black, size: 18),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: AppFontSize.large(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Banner ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.navy, AppColors.blueButton],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF4A90D9).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.light.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        showTerms
                            ? Icons.description_rounded
                            : Icons.privacy_tip_rounded,
                        color: AppColors.light,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: TextStyle(
                                  color: AppColors.light,
                                  fontSize: AppFontSize.medium(context),
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Last updated: January 2025',
                              style: TextStyle(
                                  color: AppColors.light.withValues(alpha: 0.7), 
                                  fontSize: AppFontSize.small(context))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sections ────────────────────────────────────────
              if (!showTerms) ...[
                _policySection(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: '1. Information We Collect',
                  body:
                      'We collect information you provide directly to us, such as when you create an account, make a transaction, or contact us for support. This includes:\n\n• Personal identifiers: name, email address, phone number, date of birth, and PAN number.\n• Financial data: account numbers, transaction history, and balance information.\n• Device data: IP address, browser type, operating system, and usage patterns.',
                ),
                _policySection(
                  context,
                  icon: Icons.settings_ethernet_rounded,
                  title: '2. How We Use Your Information',
                  body:
                      'We use the information we collect to:\n\n• Operate, maintain, and improve our services.\n• Process transactions and send you related information.\n• Send promotional communications (with your consent).\n• Monitor and analyse trends, usage, and activities.\n• Detect and prevent fraudulent transactions.',
                ),
                _policySection(
                  context,
                  icon: Icons.share_rounded,
                  title: '3. Information Sharing',
                  body:
                      'We do not sell your personal information. We may share information with:\n\n• Service providers who perform services on our behalf.\n• Regulatory authorities as required by law (RBI, SEBI).\n• Other financial institutions for settlement purposes.\n• Third parties with your explicit consent.',
                ),
                _policySection(
                  context,
                  icon: Icons.shield_rounded,
                  title: '4. Data Security',
                  body:
                      'We employ industry-standard encryption (AES-256) for data at rest and TLS 1.3 for data in transit. All sensitive data is tokenised and stored in ISO 27001 certified data centres located in India. We conduct regular penetration testing and security audits.',
                ),
                _policySection(
                  context,
                  icon: Icons.person_rounded,
                  title: '5. Your Rights',
                  body:
                      'You have the right to:\n\n• Access the personal data we hold about you.\n• Correct inaccurate personal data.\n• Request deletion of your personal data.\n• Object to processing of your personal data.\n• Request data portability.\n\nTo exercise any of these rights, contact our Data Protection Officer at dpo@profinch.in.',
                ),
                _policySection(
                  context,
                  icon: Icons.cookie_outlined,
                  title: '6. Cookies & Tracking',
                  body:
                      'Our app uses device identifiers and analytics SDKs to understand how users interact with our services. You can opt out of analytics tracking in Settings → Privacy. Functional cookies are necessary for the app to work correctly and cannot be disabled.',
                ),
                _policySection(
                  context,
                  icon: Icons.child_care_rounded,
                  title: '7. Children\'s Privacy',
                  body:
                      'Our services are not directed to individuals under 18 years of age. We do not knowingly collect personal information from children. If we become aware that a child has provided personal information, we will delete it immediately.',
                ),
                _policySection(
                  context,
                  icon: Icons.update_rounded,
                  title: '8. Changes to This Policy',
                  body:
                      'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and sending you a push notification. Your continued use of our services after the changes take effect constitutes your acceptance.',
                ),
              ] else ...[
                _policySection(
                  context,
                  icon: Icons.handshake_rounded,
                  title: '1. Acceptance of Terms',
                  body:
                      'By accessing or using the ProFinch mobile application, you agree to be bound by these Terms and Conditions and our Privacy Policy. If you do not agree to these terms, please do not use our services.',
                ),
                _policySection(
                  context,
                  icon: Icons.account_circle_rounded,
                  title: '2. Account Registration',
                  body:
                      'You must provide accurate and complete information when registering. You are responsible for maintaining the confidentiality of your credentials and for all activity that occurs under your account. Notify us immediately of any unauthorised use.',
                ),
                _policySection(
                  context,
                  icon: Icons.payments_rounded,
                  title: '3. Financial Services',
                  body:
                      'ProFinch provides banking services regulated by the Reserve Bank of India (RBI). All transactions are subject to applicable regulatory limits. We reserve the right to refuse or reverse transactions that appear fraudulent or violate applicable laws.',
                ),
                _policySection(
                  context,
                  icon: Icons.gavel_rounded,
                  title: '4. Prohibited Activities',
                  body:
                      'You agree not to:\n\n• Use the services for money laundering or financing illegal activities.\n• Attempt to gain unauthorised access to our systems.\n• Use automated tools to access the service.\n• Engage in transactions that violate applicable laws.\n• Provide false or misleading information.',
                ),
                _policySection(
                  context,
                  icon: Icons.balance_rounded,
                  title: '5. Limitation of Liability',
                  body:
                      'To the maximum extent permitted by law, ProFinch shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the services. Our total liability shall not exceed the amount of fees paid by you in the past 3 months.',
                ),
                _policySection(
                  context,
                  icon: Icons.location_on_rounded,
                  title: '6. Governing Law',
                  body:
                      'These Terms shall be governed by and construed in accordance with the laws of India. Any dispute arising under these Terms shall be subject to the exclusive jurisdiction of the courts in Bengaluru, Karnataka.',
                ),
              ],

              // ── Contact footer ─────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Have questions?',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: AppFontSize.body(context))),
                    const SizedBox(height: 6),
                    Text(
                      showTerms
                          ? 'Contact legal@profinch.in for any queries about these terms.'
                          : 'Reach our Data Protection Officer at dpo@profinch.in.',
                      style: TextStyle(
                          color: Color(0xFF8A9BB5), fontSize: AppFontSize.small(context), height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _policySection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF4A90D9), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: AppFontSize.body(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              color: const Color(0xFF8A9BB5),
              fontSize: AppFontSize.small(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}