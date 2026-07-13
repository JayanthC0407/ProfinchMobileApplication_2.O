import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/beneficiary_model.dart';
import '../../accounts/provider/account_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../widgets/account_selector_widget.dart';
import '../widgets/amount_input_card.dart';
import '../widgets/beneficiary_summary_card.dart';
import 'transfer_confirmation_screen.dart';

class InternationalTransferScreen extends StatefulWidget {
  final BeneficiaryModel beneficiary;

  const InternationalTransferScreen({super.key, required this.beneficiary});

  @override
  State<InternationalTransferScreen> createState() =>
      _InternationalTransferScreenState();
}

class _InternationalTransferScreenState
    extends State<InternationalTransferScreen> {
  String? selectedAccountId;
  String currency = "USD";
  String purpose = "Personal Transfer";
  final amountController = TextEditingController();
  final remarksController = TextEditingController();
  String? amountError;
  String? accountError;

  static const _currencies = ["USD", "EUR", "GBP"];
  static const _purposes = ["Personal Transfer", "Education", "Business"];

  static const _currencyFlags = {'USD': '🇺🇸', 'EUR': '🇪🇺', 'GBP': '🇬🇧'};

  @override
  Widget build(BuildContext context) {
    final accounts = Provider.of<AccountProvider>(
      context,
    ).getAccountsByUserId(Provider.of<AuthProvider>(context).currentUser!.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,

          child: _ContinueButton(
            onPressed: () {
              setState(() {
                amountError = null;
                accountError = null;
              });

              bool isValid = true;

              if (amountController.text.trim().isEmpty) {
                amountError = "Please enter transfer amount";
                isValid = false;
              }

              if (selectedAccountId == null) {
                accountError = "Please select an account";
                isValid = false;
              }

              if (!isValid) {
                setState(() {});
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransferConfirmationScreen(
                    beneficiary: widget.beneficiary,

                    accountId: selectedAccountId!,

                    amount: double.parse(amountController.text),

                    remarks: remarksController.text,

                    transferMode: "INTERNATIONAL",
                  ),
                ),
              );
            },
          ),
        ),
      ),

      body: Column(
        children: [
          _TransferHeader(
            title: "International Transfer",
            subtitle: "SWIFT / IBAN cross-border",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BeneficiarySummaryCard(
                    name: widget.beneficiary.nickname,
                    type: widget.beneficiary.beneficiaryType,
                    accountNumber: widget.beneficiary.accountNumber,
                  ),
                  const SizedBox(height: 10),
                  // Int'l info chips
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          icon: Icons.public_outlined,
                          color: const Color(0xFFB45309),
                          label:
                              "Country: ${widget.beneficiary.country ?? '—'}",
                        ),
                        const SizedBox(height: 4),
                        _InfoRow(
                          icon: Icons.numbers_outlined,
                          color: const Color(0xFFB45309),
                          label:
                              "IBAN: ${widget.beneficiary.ibanNumber ?? '—'}",
                        ),
                        const SizedBox(height: 4),
                        _InfoRow(
                          icon: Icons.swap_horiz_outlined,
                          color: const Color(0xFFB45309),
                          label:
                              "SWIFT: ${widget.beneficiary.swiftCode ?? '—'}",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AmountInputCard(controller: amountController),

                      if (amountError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            amountError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Currency selector
                  Text(
                    "CURRENCY",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _currencies.map((c) {
                      final active = currency == c;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => currency = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFB45309)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: active
                                    ? const Color(0xFFB45309)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _currencyFlags[c] ?? '',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  c,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: active
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountSelectorWidget(
                        accounts: accounts,
                        selectedAccountId: selectedAccountId,
                        onChanged: (v) {
                          setState(() {
                            selectedAccountId = v;

                            if (v != null) {
                              accountError = null;
                            }
                          });
                        },
                      ),

                      if (accountError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            accountError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DropdownSection(
                    label: "PURPOSE",
                    value: purpose,
                    items: _purposes,
                    onChanged: (v) => setState(() => purpose = v!),
                  ),
                  const SizedBox(height: 16),
                  _RemarksField(controller: remarksController),
                  const SizedBox(height: 8),
                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "International transfers may take 1–3 business days and are subject to forex charges.",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                  _ContinueButton(
                    onPressed: () {
                      if (selectedAccountId == null ||
                          amountController.text.isEmpty) {
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransferConfirmationScreen(
                            beneficiary: widget.beneficiary,
                            accountId: selectedAccountId!,
                            amount: double.parse(amountController.text),
                            remarks: remarksController.text,
                            transferMode: "INTERNATIONAL",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Shared private widgets used only in this file ───────────────────────────

class _TransferHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TransferHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3A6B), Color(0xFF2563B0)],
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownSection extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownSection({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF2563B0),
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _RemarksField extends StatelessWidget {
  final TextEditingController controller;

  const _RemarksField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "REMARKS (OPTIONAL)",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: controller,
            maxLines: 2,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Add a note...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(
                Icons.notes_outlined,
                color: Colors.grey.shade400,
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563B0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: const Text(
          "Continue",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
