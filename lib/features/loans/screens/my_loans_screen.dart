import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:provider/provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/loan_provider.dart';
import '../widgets/loan_card.dart';
import 'loan_details_screen.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final loanProvider = Provider.of<LoanProvider>(context);
    final user = authProvider.currentUser!;
    final loans = loanProvider.getLoansByUser(user.id);
    final activeLoans = loans.where((l) => l.status == 'ACTIVE').toList();
    final closedLoans = loans.where((l) => l.status == 'CLOSED').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.light,
        title: const Text(
          "My Loans",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.light,
          indicatorWeight: 3,
          labelColor: AppColors.light,
          unselectedLabelColor: AppColors.light.withValues(alpha:0.54),
          labelStyle:  TextStyle(fontWeight: FontWeight.w600, fontSize: AppFontSize.body(context)),
          tabs: [
            Tab(text: "Active (${activeLoans.length})"),
            Tab(text: "Closed (${closedLoans.length})"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LoansList(
            loans: activeLoans,
            emptyMessage: "No active loans",
            emptyIcon: Icons.check_circle_outline,
          ),
          _LoansList(
            loans: closedLoans,
            emptyMessage: "No closed loans",
            emptyIcon: Icons.history,
          ),
        ],
      ),
    );
  }
}

class _LoansList extends StatelessWidget {
  final List loans;
  final String emptyMessage;
  final IconData emptyIcon;

  const _LoansList({
    required this.loans,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: AppFontSize.medium(context),
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        return LoanCard(
          loan: loan,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LoanDetailsScreen(loan: loan),
            ),
          ),
        );
      },
    );
  }
}
