import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../provider/bills_provider.dart';

class AddBillerScreen extends StatefulWidget {
  final BillCategory? prefillCategory;

  const AddBillerScreen({super.key, this.prefillCategory});

  @override
  State<AddBillerScreen> createState() => _AddBillerScreenState();
}

class _AddBillerScreenState extends State<AddBillerScreen> {
  late BillCategory _selectedCategory;
  final _nicknameController = TextEditingController();
  final _providerController = TextEditingController();
  final _consumerNumberController = TextEditingController();
  bool _enableReminder = true;
  bool _enableAutopay = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.prefillCategory ?? BillCategory.electricity;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _providerController.dispose();
    _consumerNumberController.dispose();
    super.dispose();
  }

  void _handleAddBiller(BuildContext context) {
    if (_nicknameController.text.trim().isEmpty ||
        _providerController.text.trim().isEmpty ||
        _consumerNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    context.read<BillsProvider>().addBiller(BillerModel(
          id: 'BLR${DateTime.now().millisecondsSinceEpoch}',
          nickname: _nicknameController.text.trim(),
          providerName: _providerController.text.trim(),
          category: _selectedCategory,
          consumerNumber: _consumerNumberController.text.trim(),
          dueAmount: 0.0,
          dueDate: DateTime.now().add(const Duration(days: 30)),
          status: BillerStatus.paid,
          reminderEnabled: _enableReminder,
          autopayEnabled: _enableAutopay,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Biller added successfully!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Biller',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _sectionLabel('Bill Category'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BillCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.color : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? cat.color
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon,
                            size: 16,
                            color:
                                isSelected ? Colors.white : cat.color),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            _sectionLabel('Nickname'),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: _inputDecoration(
                  hint: 'e.g. Home Electricity',
                  icon: Icons.label_outline_rounded),
            ),

            const SizedBox(height: 16),

            _sectionLabel('Provider Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _providerController,
              decoration: _inputDecoration(
                  hint: 'e.g. BESCOM, Airtel, ACT Fibernet',
                  icon: Icons.business_outlined),
            ),

            const SizedBox(height: 16),

            _sectionLabel('Consumer / Account Number'),
            const SizedBox(height: 8),
            TextField(
              controller: _consumerNumberController,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              decoration: _inputDecoration(
                  hint: 'Enter your consumer number',
                  icon: Icons.numbers_rounded),
            ),

            const SizedBox(height: 20),

            // ── Reminder & Autopay ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _enableReminder,
                    onChanged: (v) =>
                        setState(() => _enableReminder = v),
                    activeColor: AppColors.primary,
                    title: const Text('Bill Reminders',
                        style: TextStyle(fontSize: 13)),
                    subtitle: Text('Get notified before due date',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _enableAutopay,
                    onChanged: (v) =>
                        setState(() => _enableAutopay = v),
                    activeColor: AppColors.primary,
                    title: const Text('Enable Autopay',
                        style: TextStyle(fontSize: 13)),
                    subtitle: Text(
                        'Automatically pay bills on due date',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _handleAddBiller(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Biller',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF555555)));

  InputDecoration _inputDecoration(
          {required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      );
}