import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/utils/currency_formatter.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';

class BalanceCard extends StatefulWidget {
  final List<AccountModel> accounts;
  final String selectedAccountId;
  final bool isBalanceHidden;
  final VoidCallback onToggleVisibility;
  final Function(String?) onChanged;

  // Keep old individual fields for backward compat —
  // they're ignored now since we derive everything from accounts list
  final double balance;
  final String accountNumber;
  final String accountType;

  const BalanceCard({
    super.key,
    required this.accounts,
    required this.selectedAccountId,
    required this.isBalanceHidden,
    required this.onToggleVisibility,
    required this.onChanged,
    required this.balance,
    required this.accountNumber,
    required this.accountType,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  late PageController _pageController;
  int _currentIndex = 0;

  // Different gradient per card so each account feels distinct
  static const List<List<Color>> _gradients = [
    [Color(0xFFFFFFFF), Color(0xFFCDD3E9)], // white → blue-grey (original)
    [Color(0xFFE8F5E9), Color(0xFFB2DFDB)], // light green → teal
    [Color(0xFFFCE4EC), Color(0xFFE1BEE7)], // light pink → purple
    [Color(0xFFFFF8E1), Color(0xFFFFCCBC)], // light amber → orange
  ];

  @override
  void initState() {
    super.initState();

    // Start on the account that was previously selected
    _currentIndex = widget.accounts.indexWhere(
      (a) => a.id == widget.selectedAccountId,
    );
    if (_currentIndex < 0) _currentIndex = 0;

    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.92, // peek at next card edge
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Color> _gradientFor(int index) => _gradients[index % _gradients.length];

  @override
  Widget build(BuildContext context) {
    if (widget.accounts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // ── Swipeable cards ───────────────────────────────────
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.accounts.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              // Notify dashboard of the newly visible account
              widget.onChanged(widget.accounts[index].id);
            },
            itemBuilder: (context, index) {
              final account = widget.accounts[index];
              final gradient = _gradientFor(index);

              return AnimatedScale(
                scale: _currentIndex == index ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: gradient.last.withValues(alpha: 0.5),
                    //     blurRadius: 16,
                    //     offset: const Offset(0, 6),
                    //   ),
                    // ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              account.accountType,
                              style: TextStyle(
                                color: const Color.fromARGB(179, 4, 27, 107),
                                fontSize: AppFontSize.large(context),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: widget.onToggleVisibility,
                            child: Icon(
                              widget.isBalanceHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Balance
                      Text(
                        CurrencyFormatter.format(
                          account.availableBalance,
                          account.currencyCode,
                          hideValue: widget.isBalanceHidden,
                        ),
                        style: TextStyle(
                          color: const Color.fromARGB(255, 31, 4, 122),
                          fontSize: RT.fs(context, 30),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Account number
                      Text(
                        widget.isBalanceHidden
                            ? '•••• •••• ${account.accountNumber.length >= 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}'
                            : account.accountNumber,
                        style: const TextStyle(
                          color: Color.fromARGB(179, 55, 3, 133),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ── Dot indicators ────────────────────────────────────
        if (widget.accounts.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.accounts.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                ),
              );
            }),
          ),
      ],
    );
  }
}
