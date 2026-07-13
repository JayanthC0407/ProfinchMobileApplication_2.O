import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

class WalletSendSheet extends StatefulWidget {
  final double walletBalance;
  final String? prefillUpiId;
  final Future<bool> Function({
    required String receiverName,
    required String receiverUpiId,
    required double amount,
    required String note,
  }) onSend;

  const WalletSendSheet({
    super.key,
    required this.walletBalance,
    required this.onSend,
    this.prefillUpiId,
  });

  @override
  State<WalletSendSheet> createState() => _WalletSendSheetState();
}

class _WalletSendSheetState extends State<WalletSendSheet> {
  final _upiController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  bool _success = false;
  bool _failed = false;

  final List<int> _quickAmounts = [100, 200, 500, 1000];

  @override
  void initState() {
    super.initState();
    if (widget.prefillUpiId != null) {
      _upiController.text = widget.prefillUpiId!;
    }
  }

  @override
  void dispose() {
    _upiController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final name = _nameController.text.trim();
    final upi = _upiController.text.trim();

    if (amount <= 0 || name.isEmpty || upi.isEmpty) return;

    if (amount > widget.walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Insufficient wallet balance'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await widget.onSend(
      receiverName: name,
      receiverUpiId: upi,
      amount: amount,
      note: _noteController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _success = result;
      _failed = !result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _success || _failed
            ? _buildResult(formatter)
            : _buildForm(formatter),
      ),
    );
  }

  // ── Result screen ──────────────────────────────────────────────
  Widget _buildResult(NumberFormat formatter) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _success ? Colors.green.shade50 : Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _success ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: _success ? Colors.green.shade600 : Colors.red.shade600,
            size: 40,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _success ? 'Payment Successful!' : 'Payment Failed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _success ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₹${formatter.format(amount)} ${_success ? 'paid from wallet' : 'could not be sent'}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Done',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Send form ──────────────────────────────────────────────────
  Widget _buildForm(NumberFormat formatter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Header ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Send from Wallet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0A3D62).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '₹${formatter.format(widget.walletBalance)} available',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF0A3D62),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── UPI ID ───────────────────────────────────────────
        _inputField(
          controller: _upiController,
          hint: 'name@bank or phone number',
          label: 'UPI ID',
          icon: Icons.alternate_email_rounded,
        ),

        const SizedBox(height: 12),

        // ── Name ─────────────────────────────────────────────
        _inputField(
          controller: _nameController,
          hint: 'Receiver name',
          label: 'Name',
          icon: Icons.person_outline_rounded,
        ),

        const SizedBox(height: 12),

        // ── Amount ───────────────────────────────────────────
        _inputField(
          controller: _amountController,
          hint: '0.00',
          label: 'Amount (₹)',
          icon: Icons.currency_rupee_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),

        const SizedBox(height: 10),

        // ── Quick amounts ─────────────────────────────────────
        Wrap(
          spacing: 8,
          children: _quickAmounts.map((amt) {
            return GestureDetector(
              onTap: () =>
                  setState(() => _amountController.text = amt.toString()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Text('₹$amt',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // ── Note ─────────────────────────────────────────────
        _inputField(
          controller: _noteController,
          hint: 'Add a note (optional)',
          label: 'Note',
          icon: Icons.note_outlined,
          maxLength: 50,
        ),

        const SizedBox(height: 20),

        // ── Send button ───────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : const Text('Send from Wallet',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon:
                Icon(icon, size: 18, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}