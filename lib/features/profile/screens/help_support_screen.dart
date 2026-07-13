import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchController = TextEditingController();
  int? _expandedFaq;

  final _faqs = [
    {
      'q': 'How do I reset my transaction PIN?',
      'a':
          'Go to Profile → Security Settings → Change Transaction PIN. You will need to verify your identity with an OTP sent to your registered mobile number before setting a new PIN.',
    },
    {
      'q': 'My transfer failed but money was debited. What should I do?',
      'a':
          'Failed transactions are automatically reversed within 2–3 business days. If you don\'t see the reversal, please raise a ticket using the "Raise a Ticket" option below and our team will resolve it within 24 hours.',
    },
    {
      'q': 'How do I add a new beneficiary?',
      'a':
          'Navigate to Beneficiaries from the main menu. Tap "Add Beneficiary", enter the account details, and verify using the OTP sent to your phone. New beneficiaries are activated after a 30-minute cooling period.',
    },
    {
      'q': 'What are the daily UPI transaction limits?',
      'a':
          'The default UPI limit is ₹1,00,000 per transaction and ₹5,00,000 per day. You can view and request changes to your limits in Profile → Security Settings → Transaction Limits.',
    },
    {
      'q': 'How do I block my debit card?',
      'a':
          'Go to Cards → Select your card → Block Card. This is an instant action. You can also call our 24×7 helpline at 1800-103-0000 to block your card immediately.',
    },
    {
      'q': 'How do I update my KYC?',
      'a':
          'Visit your nearest branch with your Aadhaar card and PAN card for in-person KYC. Alternatively, our Video KYC feature allows you to complete the process from home — look for "Video KYC" in the Profile section.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _searchController.text.isEmpty
        ? _faqs
        : _faqs.where((f) {
            final q = _searchController.text.toLowerCase();
            return (f['q'] ?? '').toLowerCase().contains(q) ||
                (f['a'] ?? '').toLowerCase().contains(q);
          }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
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
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightBlue),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.black, size: 18),
            ),
          ),
          title: Text(
            'Help & Support',
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

              // ── Contact options ───────────────────────────────
              Row(
                children: [
                  _contactCard(
                    context,
                    icon: Icons.headset_mic_rounded,
                    label: 'Call Us',
                    sub: '24×7 Helpline',
                    color: const Color(0xFF4A90D9),
                    onTap: () => _showCallOptions(context),
                  ),
                  const SizedBox(width: 12),
                  _contactCard(
                    context,
                    icon: Icons.chat_bubble_rounded,
                    label: 'Live Chat',
                    sub: 'Avg. wait: 2 min',
                    color: const Color(0xFF10B981),
                    onTap: () => _showLiveChat(context),
                  ),
                  const SizedBox(width: 12),
                  _contactCard(
                    context,
                    icon: Icons.email_rounded,
                    label: 'Email',
                    sub: 'Reply in 24h',
                    color: const Color(0xFFF59E0B),
                    onTap: () => _showEmailSupport(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Raise a ticket ────────────────────────────────
              GestureDetector(
                onTap: () => _showRaiseTicket(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A6E), Color(0xFF1A2F5A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF4A90D9).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90D9).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.confirmation_number_rounded,
                            color: Color(0xFF4A90D9), size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Raise a Support Ticket',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 3),
                            Text('Report issues, disputes, or complaints',
                                style: TextStyle(
                                    color: Color(0xFF8A9BB5), fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: Color(0xFF8A9BB5)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Search FAQs ───────────────────────────────────
              Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppFontSize.xs(context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2640),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2E3A57)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search FAQs…',
                    hintStyle: TextStyle(
                        color: Color(0xFF8A9BB5), fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Color(0xFF4A90D9), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // FAQ accordions
              if (filteredFaqs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No results for "${_searchController.text}"',
                      style: const TextStyle(
                          color: Color(0xFF8A9BB5), fontSize: 13),
                    ),
                  ),
                )
              else
                ...filteredFaqs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final faq = entry.value;
                  final isExpanded = _expandedFaq == i;

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _expandedFaq = isExpanded ? null : i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isExpanded ? 16 : 14),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? AppColors.background
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isExpanded
                              ? const Color(0xFF4A90D9).withOpacity(0.3)
                              : AppColors.background,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faq['q'] ?? '',
                                  style: TextStyle(
                                    color: isExpanded
                                        ? const Color(0xFF4A90D9)
                                        : AppColors.textDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            Text(
                              faq['a'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFF8A9BB5),
                                fontSize: 12,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // ── Grievance & RBI section ────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color:AppColors.background),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_rounded,
                            color: Color(0xFF4A90D9), size: 18),
                        SizedBox(width: 8),
                        Text('Banking Ombudsman',
                            style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'If your complaint is not resolved within 30 days, you may approach the RBI Banking Ombudsman at cms.rbi.org.in.',
                      style: TextStyle(
                          color: Color(0xFF8A9BB5),
                          fontSize: 12,
                          height: 1.5),
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

  Widget _contactCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                  ],
                ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(sub,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.light, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCallOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Call Us',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _callOption('General Support', '1800-103-0000', 'Toll Free • 24×7'),
            const SizedBox(height: 10),
            _callOption('Card Hotline', '1800-103-1111',
                'To block / unblock cards • 24×7'),
            const SizedBox(height: 10),
            _callOption('Loan Support', '1800-103-2222', 'Mon–Sat, 9 AM–6 PM'),
          ],
        ),
      ),
    );
  }

  Widget _callOption(String title, String number, String hours) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_rounded,
              color: Color(0xFF4A90D9), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text('$number  •  $hours',
                    style: const TextStyle(
                        color: AppColors.navyDark, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.call_rounded,
              color: Color(0xFF4CD964), size: 20),
        ],
      ),
    );
  }

  void _showLiveChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightBlue,
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
                color: const Color(0xFF10B981).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_rounded,
                  color: Color(0xFF10B981), size: 28),
            ),
            const SizedBox(height: 16),
            const Text('Live Chat',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'An agent is available now. Average wait time is 2 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Start Chat',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email Support',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('We aim to respond within 24 hours.',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            const SizedBox(height: 20),
            _emailCard('General', 'support@profinch.in'),
            const SizedBox(height: 10),
            _emailCard('Disputes', 'disputes@profinch.in'),
            const SizedBox(height: 10),
            _emailCard('Data Privacy', 'dpo@profinch.in'),
          ],
        ),
      ),
    );
  }

  Widget _emailCard(String label, String email) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_rounded,
              color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(email,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.copy_rounded,
              color:AppColors.textPrimary, size: 16),
        ],
      ),
    );
  }

  void _showRaiseTicket(BuildContext context) {
    final subjectController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor:AppColors.lightBlue,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Raise a Support Ticket',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('We will respond within 24 hours.',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            const SizedBox(height: 20),
            _ticketField(subjectController, 'Subject'),
            const SizedBox(height: 12),
            _ticketField(descController, 'Describe your issue', maxLines: 4),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Submit Ticket',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketField(TextEditingController ctrl, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.background),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.background),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF4A90D9), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}