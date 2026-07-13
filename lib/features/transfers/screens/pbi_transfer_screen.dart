import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/beneficiary_model.dart';
import '../../accounts/provider/account_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../widgets/account_selector_widget.dart';
import '../widgets/amount_input_card.dart';
import '../widgets/beneficiary_summary_card.dart';
import 'transfer_confirmation_screen.dart';

class PbiTransferScreen extends StatefulWidget {
  final BeneficiaryModel beneficiary;

  const PbiTransferScreen({super.key, required this.beneficiary});

  @override
  State<PbiTransferScreen> createState() => _PbiTransferScreenState();
}

class _PbiTransferScreenState extends State<PbiTransferScreen> {
  String purpose = "Self Transfer";
  String? selectedAccountId;
  final amountController = TextEditingController();
  final remarksController = TextEditingController();
  String? amountError;
  String? accountError;

  static const _purposes = [
    "Self Transfer",
    "Family Support",
    "Rent Payment",
    "Utility Bills",
    "Education",
    "Investment",
    "Others",
  ];

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

                    transferMode: "PBI",
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
            title: "PBI Transfer",
            subtitle: "ProFinch internal transfer",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  BeneficiarySummaryCard(
                    name: widget.beneficiary.nickname,
                    type: widget.beneficiary.beneficiaryType,
                    accountNumber: widget.beneficiary.accountNumber,
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
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
