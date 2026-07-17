import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/features/Beneficiaries/provider/beneficiary_provider.dart';
import 'package:profinch_mobile_application/features/Beneficiaries/screens/beneficiaries_screen.dart';
import 'package:profinch_mobile_application/features/Beneficiaries/screens/beneficiary_type_screen.dart';
import 'package:profinch_mobile_application/features/Transactions/provider/transaction_provider.dart';
import 'package:profinch_mobile_application/features/Transactions/screens/transaction_history_screen.dart';
import 'package:profinch_mobile_application/features/analytics/screens/analytics_screen.dart';
import 'package:profinch_mobile_application/features/calculators/screens/calculator_menu_screen.dart';
import 'package:profinch_mobile_application/features/calculators/screens/currency_converter_screen.dart';
import 'package:profinch_mobile_application/features/calculators/screens/loan_eligibility_screen.dart';
import 'package:profinch_mobile_application/features/calculators/screens/sip_calculator_screen.dart';
import 'package:profinch_mobile_application/features/calculators/screens/term_deposit_calculator_screen.dart';
import 'package:profinch_mobile_application/features/cards/provider/card_provider.dart';
import 'package:profinch_mobile_application/features/cards/screens/apply_card_screen.dart';
import 'package:profinch_mobile_application/features/cards/screens/card_screen.dart';
import 'package:profinch_mobile_application/features/accounts/screens/accounts_screen.dart';
import 'package:profinch_mobile_application/features/insurance/provider/insurance_provider.dart';
import 'package:profinch_mobile_application/features/insurance/screens/buy_insurance_screen.dart';
import 'package:profinch_mobile_application/features/insurance/screens/insurance_claims_screen.dart';
import 'package:profinch_mobile_application/features/insurance/screens/insurance_screen.dart';
import 'package:profinch_mobile_application/features/insurance/screens/my_policies_screen.dart';
import 'package:profinch_mobile_application/features/loans/provider/loan_provider.dart';
import 'package:profinch_mobile_application/features/loans/screens/apply_loan_screen.dart';
import 'package:profinch_mobile_application/features/loans/screens/emi_calculator_screen.dart';
import 'package:profinch_mobile_application/features/loans/screens/my_loans_screen.dart';
import 'package:profinch_mobile_application/features/payments/provider/payment_provider.dart';
import 'package:profinch_mobile_application/features/payments/screens/adhoc_transfer_screen.dart';
import 'package:profinch_mobile_application/features/payments/screens/favourites_screen.dart';
import 'package:profinch_mobile_application/features/payments/screens/payments_home_screen.dart';
import 'package:profinch_mobile_application/features/payments/screens/scheduled_payment_screen.dart';
import 'package:profinch_mobile_application/features/profile/screens/profile_screen.dart';
import 'package:profinch_mobile_application/features/transfers/provider/transfer_provider.dart';
import 'package:profinch_mobile_application/features/transfers/screens/transfer_money_screen.dart';

import 'package:profinch_mobile_application/features/upi/screens/upi_home_screen.dart';
import 'package:profinch_mobile_application/features/term_deposit/provider/term_deposit_provider.dart';
import 'package:profinch_mobile_application/features/term_deposit/screens/term_deposit_screen.dart';
import 'package:profinch_mobile_application/features/term_deposit/screens/my_term_deposits_screen.dart';
import 'package:profinch_mobile_application/features/term_deposit/screens/open_term_deposit_screen.dart';
import 'package:profinch_mobile_application/features/term_deposit/screens/redeem_term_deposit_screen.dart';
import 'package:profinch_mobile_application/features/term_deposit/screens/term_deposit_statement_screen.dart';
import 'package:profinch_mobile_application/features/wallet/screens/wallet_screen.dart';

import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/dashboard/provider/dashboard_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/accounts/provider/account_provider.dart';
import 'features/loans/screens/loans_screen.dart';

import 'package:profinch_mobile_application/features/rewards/screens/reward_screen.dart';

import 'package:profinch_mobile_application/features/bills/screens/bills_screen.dart';

import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';
import 'package:profinch_mobile_application/features/notifications/screens/notification_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:profinch_mobile_application/core/l10n/app_localizations.dart';
import 'package:profinch_mobile_application/features/profile/provider/language_provider.dart';
import 'package:profinch_mobile_application/features/bills/provider/bills_provider.dart';
import 'package:profinch_mobile_application/features/profile/provider/profile_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => TermDepositProvider()),
        ChangeNotifierProvider(create: (_) => BeneficiaryProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => InsuranceProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider.value(value: TransactionProvider.instance),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(
          create: (ctx) => BillsProvider(
            ctx.read<AuthProvider>(),
            ctx.read<AccountProvider>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageProvider>().locale;

    return MaterialApp(
      title: 'Profinch Bank',
      debugShowCheckedModeBanner: false,

      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 165, 24, 64),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.cards: (context) => const CardsScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.accounts: (context) => const AccountsScreen(),

        AppRoutes.transactions: (context) => const TransactionHistoryScreen(),
        AppRoutes.upi: (context) => const UpiHomeScreen(),

        AppRoutes.termDeposits: (context) => const TermDepositScreen(),
        AppRoutes.myDeposits: (context) => const MyTermDepositsScreen(),
        AppRoutes.openDeposit: (context) => const OpenTermDepositScreen(),
        AppRoutes.redeemDeposit: (context) => const RedeemTermDepositScreen(),
        AppRoutes.depositStatements: (context) =>
            const TermDepositStatementScreen(),

        AppRoutes.beneficiaries: (context) => const BeneficiariesScreen(),
        AppRoutes.beneficiaryType: (context) => const BeneficiaryTypeScreen(),

        AppRoutes.loans: (context) => const LoansScreen(),
        AppRoutes.myLoans: (context) => const MyLoansScreen(),
        AppRoutes.applyLoan: (context) => const ApplyLoanScreen(),
        AppRoutes.emiCalculator: (context) => const EmiCalculatorScreen(),
        AppRoutes.wallet: (context) => const WalletScreen(),
        AppRoutes.calculators: (context) => const CalculatorMenuScreen(),
        AppRoutes.tdCalculator: (context) =>
            const TermDepositCalculatorScreen(),
        AppRoutes.loanEligibility: (context) => const LoanEligibilityScreen(),
        AppRoutes.currencyConverter: (context) =>
            const CurrencyConverterScreen(),
        AppRoutes.sipCalculator: (context) => const SipCalculatorScreen(),
        AppRoutes.applyCard: (context) => const ApplyCardScreen(),

        AppRoutes.transferMoney: (context) => const TransferMoneyScreen(),
        AppRoutes.rewards: (context) => const RewardsScreen(),
        AppRoutes.bills: (context) => const BillsScreen(),
        AppRoutes.notifications: (context) => const NotificationScreen(),

        AppRoutes.insurance: (context) => const InsuranceScreen(),
        AppRoutes.myPolicies: (context) => const MyPoliciesScreen(),
        AppRoutes.buyInsurance: (context) => const BuyInsuranceScreen(),
        AppRoutes.insuranceClaims: (context) => const InsuranceClaimsScreen(),
        AppRoutes.payments: (context) => const PaymentsHomeScreen(),
        AppRoutes.adhocTransfer: (context) => const AdhocTransferScreen(),
        AppRoutes.scheduledPayment: (context) => const ScheduledPaymentScreen(),
        AppRoutes.favourites: (context) => const FavouritesScreen(),
        AppRoutes.analytics: (_) => const AnalyticsScreen(),
      },
    );
  }
}
