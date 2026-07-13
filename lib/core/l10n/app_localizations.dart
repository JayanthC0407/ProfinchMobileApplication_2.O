import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AppLocalizations
//  Single-file, zero-dependency localisation. No code-gen, no ARB files.
//
//  Usage anywhere in the widget tree:
//    final t = AppLocalizations.of(context);
//    Text(t.dashboard_welcomeBack)
//
//  To add a new language:
//    1. Add its locale to supportedLocales below.
//    2. Add a new _<lang>Strings() factory below.
//    3. Add it to the switch in AppLocalizations._byLocale().
// ─────────────────────────────────────────────────────────────────────────────

class AppLocalizations {
  AppLocalizations._(this.locale, this._s);

  final Locale locale;
  final _Strings _s;

  // ── Lookup ─────────────────────────────────────────────────────
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'), // English (India)
    Locale('hi'), // Hindi
    Locale('kn'), // Kannada
    Locale('ta'), // Tamil
    Locale('te'), // Telugu
    Locale('mr'), // Marathi
  ];

  // ── Language name → Locale ─────────────────────────────────────
  // Used by LanguageProvider to convert display name to a Locale.
  static const Map<String, Locale> nameToLocale = {
    'English (India)': Locale('en'),
    'Hindi': Locale('hi'),
    'Kannada': Locale('kn'),
    'Tamil': Locale('ta'),
    'Telugu': Locale('te'),
    'Marathi': Locale('mr'),
  };

  static Map<Locale, String> localeToName = {
    Locale('en'): 'English (India)',
    Locale('hi'): 'Hindi',
    Locale('kn'): 'Kannada',
    Locale('ta'): 'Tamil',
    Locale('te'): 'Telugu',
    Locale('mr'): 'Marathi',
  };

  // ── Internal factory ───────────────────────────────────────────
  static AppLocalizations _byLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return AppLocalizations._(locale, _HiStrings());
      case 'kn':
        return AppLocalizations._(locale, _KnStrings());
      case 'ta':
        return AppLocalizations._(locale, _TaStrings());
      case 'te':
        return AppLocalizations._(locale, _TeStrings());
      case 'mr':
        return AppLocalizations._(locale, _MrStrings());
      default:
        return AppLocalizations._(locale, _EnStrings());
    }
  }

  // ── Public string getters ──────────────────────────────────────
  // Dashboard
  String get dashboard_welcomeBack => _s.dashboard_welcomeBack;
  String get dashboard_totalBalance => _s.dashboard_totalBalance;
  String get dashboard_send => _s.dashboard_send;
  String get dashboard_addMoney => _s.dashboard_addMoney;
  String get dashboard_scan => _s.dashboard_scan;
  String get dashboard_wallet => _s.dashboard_wallet;
  String get dashboard_quickAccess => _s.dashboard_quickAccess;
  String get dashboard_recentTx => _s.dashboard_recentTx;
  String get dashboard_seeAll => _s.dashboard_seeAll;
  String get dashboard_edit => _s.dashboard_edit;

  // Bottom Navbar
  String get nav_home => _s.nav_home;
  String get nav_transactions => _s.nav_transactions;
  String get nav_scan => _s.nav_scan;
  String get nav_offers => _s.nav_offers;
  String get nav_profile => _s.nav_profile;

  // Quick-access tiles
  String get qa_accounts => _s.qa_accounts;
  String get qa_cards => _s.qa_cards;
  String get qa_loans => _s.qa_loans;
  String get qa_analytics => _s.qa_analytics;
  String get qa_bills => _s.qa_bills;
  String get qa_rewards => _s.qa_rewards;
  String get qa_more => _s.qa_more;
  String get qa_beneficiary => _s.qa_beneficiary;
  String get qa_insurance => _s.qa_insurance;
  String get qa_termDeposit => _s.qa_termDeposit;
  String get qa_invest => _s.qa_invest;
  String get qa_calculators => _s.qa_calculators;
  String get qa_Less => _s.qa_Less;

  // Profile screen
  String get profile_title => _s.profile_title;
  String get profile_editBtn => _s.profile_editBtn;
  String get profile_sectionPersonal => _s.profile_sectionPersonal;
  String get profile_sectionSecurity => _s.profile_sectionSecurity;
  String get profile_sectionPrefs => _s.profile_sectionPrefs;
  String get profile_sectionSupport => _s.profile_sectionSupport;
  String get profile_phone => _s.profile_phone;
  String get profile_pan => _s.profile_pan;
  String get profile_primaryAccount => _s.profile_primaryAccount;
  String get profile_memberSince => _s.profile_memberSince;
  String get profile_security => _s.profile_security;
  String get profile_securitySub => _s.profile_securitySub;
  String get profile_linkedDevices => _s.profile_linkedDevices;
  String get profile_linkedDevicesSub => _s.profile_linkedDevicesSub;
  String get profile_loginActivity => _s.profile_loginActivity;
  String get profile_loginActivitySub => _s.profile_loginActivitySub;
  String get profile_notifications => _s.profile_notifications;
  String get profile_notifSub => _s.profile_notifSub;
  String get profile_language => _s.profile_language;
  String get profile_langSub => _s.profile_langSub;
  String get profile_statement => _s.profile_statement;
  String get profile_statementSub => _s.profile_statementSub;
  String get profile_help => _s.profile_help;
  String get profile_helpSub => _s.profile_helpSub;
  String get profile_privacy => _s.profile_privacy;
  String get profile_privacySub => _s.profile_privacySub;
  String get profile_terms => _s.profile_terms;
  String get profile_termsSub => _s.profile_termsSub;
  String get profile_rate => _s.profile_rate;
  String get profile_rateSub => _s.profile_rateSub;
  String get profile_logout => _s.profile_logout;
  String get profile_kycVerified => _s.profile_kycVerified;
  String get profile_kycPending => _s.profile_kycPending;
  String get profile_verified => _s.profile_verified;

  // Edit Profile screen
  String get editProfile_title => _s.editProfile_title;
  String get editProfile_changePhoto => _s.editProfile_changePhoto;
  String get editProfile_sectionPersonal => _s.editProfile_sectionPersonal;
  String get editProfile_sectionAccount => _s.editProfile_sectionAccount;
  String get editProfile_fullName => _s.editProfile_fullName;
  String get editProfile_email => _s.editProfile_email;
  String get editProfile_phone => _s.editProfile_phone;
  String get editProfile_selectAccount => _s.editProfile_selectAccount;
  String get editProfile_saveBtn => _s.editProfile_saveBtn;
  String get editProfile_successMsg => _s.editProfile_successMsg;
  String get editProfile_infoNote => _s.editProfile_infoNote;
  String get editProfile_errNameEmpty => _s.editProfile_errNameEmpty;
  String get editProfile_errEmailEmpty => _s.editProfile_errEmailEmpty;
  String get editProfile_errEmailInvalid => _s.editProfile_errEmailInvalid;
  String get editProfile_errPhoneEmpty => _s.editProfile_errPhoneEmpty;
  String get editProfile_errPhoneShort => _s.editProfile_errPhoneShort;

  // Security settings screen
  String get security_title => _s.security_title;
  String get security_scoreLabel => _s.security_scoreLabel;
  String get security_scoreHint => _s.security_scoreHint;
  String get security_sectionAuth => _s.security_sectionAuth;
  String get security_biometric => _s.security_biometric;
  String get security_biometricSub => _s.security_biometricSub;
  String get security_twoFa => _s.security_twoFa;
  String get security_twoFaSub => _s.security_twoFaSub;
  String get security_changeLoginPin => _s.security_changeLoginPin;
  String get security_changeLoginPinSub => _s.security_changeLoginPinSub;
  String get security_sectionTxn => _s.security_sectionTxn;
  String get security_txnPin => _s.security_txnPin;
  String get security_txnPinSub => _s.security_txnPinSub;
  String get security_changeTxnPin => _s.security_changeTxnPin;
  String get security_changeTxnPinSub => _s.security_changeTxnPinSub;
  String get security_txnLimits => _s.security_txnLimits;
  String get security_txnLimitsSub => _s.security_txnLimitsSub;
  String get security_sectionApp => _s.security_sectionApp;
  String get security_appLock => _s.security_appLock;
  String get security_appLockSub => _s.security_appLockSub;
  String get security_loginAlerts => _s.security_loginAlerts;
  String get security_loginAlertsSub => _s.security_loginAlertsSub;
  String get security_blockedMerchants => _s.security_blockedMerchants;
  String get security_blockedMerchantsSub => _s.security_blockedMerchantsSub;

  // Common / shared
  String get common_cancel => _s.common_cancel;
  String get common_confirm => _s.common_confirm;
  String get common_save => _s.common_save;
  String get common_enable => _s.common_enable;
  String get common_logOut => _s.common_logOut;
  String get common_appVersion => _s.common_appVersion;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Delegate
// ─────────────────────────────────────────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations._byLocale(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Abstract string bag
// ─────────────────────────────────────────────────────────────────────────────
abstract class _Strings {
  // Dashboard
  String get dashboard_welcomeBack;
  String get dashboard_totalBalance;
  String get dashboard_send;
  String get dashboard_addMoney;
  String get dashboard_scan;
  String get dashboard_wallet;
  String get dashboard_quickAccess;
  String get dashboard_recentTx;
  String get dashboard_seeAll;
  String get dashboard_edit;
  // Navbar
  String get nav_home;
  String get nav_transactions;
  String get nav_scan;
  String get nav_offers;
  String get nav_profile;
  // Quick access
  String get qa_accounts;
  String get qa_cards;
  String get qa_loans;
  String get qa_analytics;
  String get qa_bills;
  String get qa_rewards;
  String get qa_more;
  String get qa_beneficiary;
  String get qa_insurance;
  String get qa_termDeposit;
  String get qa_invest;
  String get qa_calculators;
  String get qa_Less;

  // Profile
  String get profile_title;
  String get profile_editBtn;
  String get profile_sectionPersonal;
  String get profile_sectionSecurity;
  String get profile_sectionPrefs;
  String get profile_sectionSupport;
  String get profile_phone;
  String get profile_pan;
  String get profile_primaryAccount;
  String get profile_memberSince;
  String get profile_security;
  String get profile_securitySub;
  String get profile_linkedDevices;
  String get profile_linkedDevicesSub;
  String get profile_loginActivity;
  String get profile_loginActivitySub;
  String get profile_notifications;
  String get profile_notifSub;
  String get profile_language;
  String get profile_langSub;
  String get profile_statement;
  String get profile_statementSub;
  String get profile_help;
  String get profile_helpSub;
  String get profile_privacy;
  String get profile_privacySub;
  String get profile_terms;
  String get profile_termsSub;
  String get profile_rate;
  String get profile_rateSub;
  String get profile_logout;
  String get profile_kycVerified;
  String get profile_kycPending;
  String get profile_verified;
  // Edit profile
  String get editProfile_title;
  String get editProfile_changePhoto;
  String get editProfile_sectionPersonal;
  String get editProfile_sectionAccount;
  String get editProfile_fullName;
  String get editProfile_email;
  String get editProfile_phone;
  String get editProfile_selectAccount;
  String get editProfile_saveBtn;
  String get editProfile_successMsg;
  String get editProfile_infoNote;
  String get editProfile_errNameEmpty;
  String get editProfile_errEmailEmpty;
  String get editProfile_errEmailInvalid;
  String get editProfile_errPhoneEmpty;
  String get editProfile_errPhoneShort;
  // Security
  String get security_title;
  String get security_scoreLabel;
  String get security_scoreHint;
  String get security_sectionAuth;
  String get security_biometric;
  String get security_biometricSub;
  String get security_twoFa;
  String get security_twoFaSub;
  String get security_changeLoginPin;
  String get security_changeLoginPinSub;
  String get security_sectionTxn;
  String get security_txnPin;
  String get security_txnPinSub;
  String get security_changeTxnPin;
  String get security_changeTxnPinSub;
  String get security_txnLimits;
  String get security_txnLimitsSub;
  String get security_sectionApp;
  String get security_appLock;
  String get security_appLockSub;
  String get security_loginAlerts;
  String get security_loginAlertsSub;
  String get security_blockedMerchants;
  String get security_blockedMerchantsSub;
  // Common
  String get common_cancel;
  String get common_confirm;
  String get common_save;
  String get common_enable;
  String get common_logOut;
  String get common_appVersion;
}

// ─────────────────────────────────────────────────────────────────────────────
//  English
// ─────────────────────────────────────────────────────────────────────────────
class _EnStrings extends _Strings {
  @override
  String get dashboard_welcomeBack => 'Welcome Back';
  @override
  String get dashboard_totalBalance => 'Total Balance';
  @override
  String get dashboard_send => 'Send';
  @override
  String get dashboard_addMoney => 'Add Money';
  @override
  String get dashboard_scan => 'Scan';
  @override
  String get dashboard_wallet => 'Wallet';
  @override
  String get dashboard_quickAccess => 'Quick Access';
  @override
  String get dashboard_recentTx => 'Recent Transactions';
  @override
  String get dashboard_seeAll => 'See All';
  @override
  String get dashboard_edit => 'Edit';
  @override
  String get nav_home => 'Home';
  @override
  String get nav_transactions => 'Transactions';
  @override
  String get nav_scan => 'Scan';
  @override
  String get nav_offers => 'Offers';
  @override
  String get nav_profile => 'Profile';
  @override
  String get qa_accounts => 'Accounts';
  @override
  String get qa_cards => 'Cards';
  @override
  String get qa_loans => 'Loans';
  @override
  String get qa_analytics => 'Analytics';
  @override
  String get qa_bills => 'Bills';
  @override
  String get qa_rewards => 'Rewards';
  @override
  String get qa_more => 'More';
  @override
  String get profile_title => 'Profile';
  @override
  String get profile_editBtn => 'Edit';
  @override
  String get profile_sectionPersonal => 'PERSONAL INFORMATION';
  @override
  String get profile_sectionSecurity => 'ACCOUNT & SECURITY';
  @override
  String get profile_sectionPrefs => 'PREFERENCES';
  @override
  String get profile_sectionSupport => 'SUPPORT & LEGAL';
  @override
  String get profile_phone => 'PHONE NUMBER';
  @override
  String get profile_pan => 'PAN NUMBER';
  @override
  String get profile_primaryAccount => 'PRIMARY ACCOUNT';
  @override
  String get profile_memberSince => 'MEMBER SINCE';
  @override
  String get profile_security => 'Security Settings';
  @override
  String get profile_securitySub => 'PIN, biometrics, 2FA';
  @override
  String get profile_linkedDevices => 'Linked Devices';
  @override
  String get profile_linkedDevicesSub => '2 devices active';
  @override
  String get profile_loginActivity => 'Login Activity';
  @override
  String get profile_loginActivitySub => 'Last login: Today, 9:41 AM';
  @override
  String get profile_notifications => 'Notifications';
  @override
  String get profile_notifSub => 'Alerts, SMS, email';
  @override
  String get profile_language => 'Language';
  @override
  String get profile_langSub => 'English (India)';
  @override
  String get profile_statement => 'Statement Preferences';
  @override
  String get profile_statementSub => 'Digital — delivered to email';
  @override
  String get profile_help => 'Help & Support';
  @override
  String get profile_helpSub => 'FAQs, live chat, call us';
  @override
  String get profile_privacy => 'Privacy Policy';
  @override
  String get profile_privacySub => 'Last updated Jan 2025';
  @override
  String get profile_terms => 'Terms & Conditions';
  @override
  String get profile_termsSub => 'User agreement';
  @override
  String get profile_rate => 'Rate the App';
  @override
  String get profile_rateSub => 'Share your feedback';
  @override
  String get profile_logout => 'Log Out';
  @override
  String get profile_kycVerified => 'KYC Verified';
  @override
  String get profile_kycPending => 'KYC Pending';
  @override
  String get profile_verified => 'Verified';
  @override
  String get editProfile_title => 'Edit Profile';
  @override
  String get editProfile_changePhoto => 'Tap to change photo';
  @override
  String get editProfile_sectionPersonal => 'PERSONAL DETAILS';
  @override
  String get editProfile_sectionAccount => 'PRIMARY ACCOUNT';
  @override
  String get editProfile_fullName => 'Full Name';
  @override
  String get editProfile_email => 'Email Address';
  @override
  String get editProfile_phone => 'Phone Number';
  @override
  String get editProfile_selectAccount => 'Select Primary Account';
  @override
  String get editProfile_saveBtn => 'Save Changes';
  @override
  String get editProfile_successMsg => 'Profile updated successfully';
  @override
  String get editProfile_infoNote =>
      'Your primary account is used for salary credits and default transactions.';
  @override
  String get editProfile_errNameEmpty => 'Name cannot be empty';
  @override
  String get editProfile_errEmailEmpty => 'Email cannot be empty';
  @override
  String get editProfile_errEmailInvalid => 'Enter a valid email address';
  @override
  String get editProfile_errPhoneEmpty => 'Phone cannot be empty';
  @override
  String get editProfile_errPhoneShort => 'Enter a valid 10-digit number';
  @override
  String get security_title => 'Security Settings';
  @override
  String get security_scoreLabel => 'Security Score';
  @override
  String get security_scoreHint => 'Good — Enable 2FA to reach Excellent';
  @override
  String get security_sectionAuth => 'AUTHENTICATION';
  @override
  String get security_biometric => 'Biometric Login';
  @override
  String get security_biometricSub => 'Use fingerprint or Face ID to sign in';
  @override
  String get security_twoFa => 'Two-Factor Authentication';
  @override
  String get security_twoFaSub => 'OTP sent to your registered mobile';
  @override
  String get security_changeLoginPin => 'Change Login PIN';
  @override
  String get security_changeLoginPinSub => '4-digit login PIN';
  @override
  String get security_sectionTxn => 'TRANSACTION SECURITY';
  @override
  String get security_txnPin => 'Transaction PIN';
  @override
  String get security_txnPinSub => 'Required for every fund transfer';
  @override
  String get security_changeTxnPin => 'Change Transaction PIN';
  @override
  String get security_changeTxnPinSub => '6-digit MPIN for payments';
  @override
  String get security_txnLimits => 'Transaction Limits';
  @override
  String get security_txnLimitsSub => 'Daily: ₹1,00,000 per transaction';
  @override
  String get security_sectionApp => 'APP SECURITY';
  @override
  String get security_appLock => 'App Lock';
  @override
  String get security_appLockSub => 'Lock app when minimised';
  @override
  String get security_loginAlerts => 'Login Alerts';
  @override
  String get security_loginAlertsSub => 'Notify on new sign-in attempts';
  @override
  String get security_blockedMerchants => 'Blocked Merchants';
  @override
  String get security_blockedMerchantsSub =>
      'Manage blocked merchant categories';
  @override
  String get common_cancel => 'Cancel';
  @override
  String get common_confirm => 'Confirm';
  @override
  String get common_save => 'Save';
  @override
  String get common_enable => 'Enable';
  @override
  String get common_logOut => 'Log Out';
  @override
  String get common_appVersion => 'ProFinch v1.0.0  •  Build 100';

  @override
  String get qa_beneficiary => 'Beneficiary';

  @override
  String get qa_calculators => 'Calculators';

  @override
  String get qa_insurance => 'Insurance';

  @override
  String get qa_invest => 'Invest';

  @override
  String get qa_termDeposit => 'Term Deposit';

  @override
  String get qa_Less => 'Less';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hindi (हिन्दी)
// ─────────────────────────────────────────────────────────────────────────────
class _HiStrings extends _Strings {
  @override
  String get dashboard_welcomeBack => 'वापस स्वागत है';
  @override
  String get dashboard_totalBalance => 'कुल शेष राशि';
  @override
  String get dashboard_send => 'भेजें';
  @override
  String get dashboard_addMoney => 'पैसे जोड़ें';
  @override
  String get dashboard_scan => 'स्कैन';
  @override
  String get dashboard_wallet => 'वॉलेट';
  @override
  String get dashboard_quickAccess => 'त्वरित पहुँच';
  @override
  String get dashboard_recentTx => 'हाल के लेन-देन';
  @override
  String get dashboard_seeAll => 'सभी देखें';
  @override
  String get dashboard_edit => 'संपादित करें';
  @override
  String get nav_home => 'होम';
  @override
  String get nav_transactions => 'लेन-देन';
  @override
  String get nav_scan => 'स्कैन';
  @override
  String get nav_offers => 'ऑफ़र';
  @override
  String get nav_profile => 'प्रोफ़ाइल';
  @override
  String get qa_accounts => 'खाते';
  @override
  String get qa_cards => 'कार्ड';
  @override
  String get qa_loans => 'ऋण';
  @override
  String get qa_analytics => 'विश्लेषण';
  @override
  String get qa_bills => 'बिल';
  @override
  String get qa_rewards => 'पुरस्कार';
  @override
  String get qa_more => 'और';
  @override
  String get qa_beneficiary => 'लाभार्थी';
  @override
  String get qa_insurance => 'बीमा';
  @override
  String get qa_termDeposit => 'अवधि जमा';
  @override
  String get qa_invest => 'निवेश';
  @override
  String get qa_calculators => 'कैलकुलेटर';
  @override
  String get qa_Less => 'कम';
  @override
  String get profile_title => 'प्रोफ़ाइल';
  @override
  String get profile_editBtn => 'संपादित करें';
  @override
  String get profile_sectionPersonal => 'व्यक्तिगत जानकारी';
  @override
  String get profile_sectionSecurity => 'खाता और सुरक्षा';
  @override
  String get profile_sectionPrefs => 'प्राथमिकताएँ';
  @override
  String get profile_sectionSupport => 'सहायता और कानूनी';
  @override
  String get profile_phone => 'फ़ोन नंबर';
  @override
  String get profile_pan => 'पैन नंबर';
  @override
  String get profile_primaryAccount => 'प्राथमिक खाता';
  @override
  String get profile_memberSince => 'सदस्य कब से';
  @override
  String get profile_security => 'सुरक्षा सेटिंग्स';
  @override
  String get profile_securitySub => 'पिन, बायोमेट्रिक्स, 2FA';
  @override
  String get profile_linkedDevices => 'लिंक्ड डिवाइस';
  @override
  String get profile_linkedDevicesSub => '2 डिवाइस सक्रिय';
  @override
  String get profile_loginActivity => 'लॉगिन गतिविधि';
  @override
  String get profile_loginActivitySub => 'अंतिम लॉगिन: आज, सुबह 9:41';
  @override
  String get profile_notifications => 'सूचनाएँ';
  @override
  String get profile_notifSub => 'अलर्ट, SMS, ईमेल';
  @override
  String get profile_language => 'भाषा';
  @override
  String get profile_langSub => 'हिन्दी';
  @override
  String get profile_statement => 'विवरण प्राथमिकताएँ';
  @override
  String get profile_statementSub => 'डिजिटल — ईमेल पर';
  @override
  String get profile_help => 'सहायता और समर्थन';
  @override
  String get profile_helpSub => 'FAQ, चैट, कॉल करें';
  @override
  String get profile_privacy => 'गोपनीयता नीति';
  @override
  String get profile_privacySub => 'अंतिम अपडेट जनवरी 2025';
  @override
  String get profile_terms => 'नियम एवं शर्तें';
  @override
  String get profile_termsSub => 'उपयोगकर्ता अनुबंध';
  @override
  String get profile_rate => 'ऐप को रेट करें';
  @override
  String get profile_rateSub => 'अपनी प्रतिक्रिया साझा करें';
  @override
  String get profile_logout => 'लॉग आउट';
  @override
  String get profile_kycVerified => 'KYC सत्यापित';
  @override
  String get profile_kycPending => 'KYC लंबित';
  @override
  String get profile_verified => 'सत्यापित';
  @override
  String get editProfile_title => 'प्रोफ़ाइल संपादित करें';
  @override
  String get editProfile_changePhoto => 'फ़ोटो बदलने के लिए टैप करें';
  @override
  String get editProfile_sectionPersonal => 'व्यक्तिगत विवरण';
  @override
  String get editProfile_sectionAccount => 'प्राथमिक खाता';
  @override
  String get editProfile_fullName => 'पूरा नाम';
  @override
  String get editProfile_email => 'ईमेल पता';
  @override
  String get editProfile_phone => 'फ़ोन नंबर';
  @override
  String get editProfile_selectAccount => 'प्राथमिक खाता चुनें';
  @override
  String get editProfile_saveBtn => 'बदलाव सहेजें';
  @override
  String get editProfile_successMsg => 'प्रोफ़ाइल सफलतापूर्वक अपडेट हुई';
  @override
String get editProfile_infoNote =>
      'आपका प्राथमिक खाता वेतन क्रेडिट और डिफ़ॉल्ट लेनदेन के लिए उपयोग किया जाता है।';
  @override
  String get editProfile_errNameEmpty => 'नाम खाली नहीं हो सकता';
  @override
  String get editProfile_errEmailEmpty => 'ईमेल खाली नहीं हो सकता';
  @override
  String get editProfile_errEmailInvalid => 'वैध ईमेल पता दर्ज करें';
  @override
  String get editProfile_errPhoneEmpty => 'फ़ोन नंबर खाली नहीं हो सकता';
  @override
  String get editProfile_errPhoneShort => 'वैध 10 अंकों का नंबर दर्ज करें';
  @override
  String get security_title => 'सुरक्षा सेटिंग्स';
  @override
  String get security_scoreLabel => 'सुरक्षा स्कोर';
  @override
  String get security_scoreHint => 'अच्छा — 2FA सक्षम करें';
  @override
  String get security_sectionAuth => 'प्रमाणीकरण';
  @override
  String get security_biometric => 'बायोमेट्रिक लॉगिन';
  @override
  String get security_biometricSub => 'फिंगरप्रिंट या फेस ID से साइन इन करें';
  @override
  String get security_twoFa => 'दो-कारक प्रमाणीकरण';
  @override
  String get security_twoFaSub => 'पंजीकृत मोबाइल पर OTP';
  @override
  String get security_changeLoginPin => 'लॉगिन PIN बदलें';
  @override
  String get security_changeLoginPinSub => '4-अंकीय लॉगिन PIN';
  @override
  String get security_sectionTxn => 'लेन-देन सुरक्षा';
  @override
  String get security_txnPin => 'लेन-देन PIN';
  @override
  String get security_txnPinSub => 'हर ट्रांसफर के लिए आवश्यक';
  @override
  String get security_changeTxnPin => 'लेन-देन PIN बदलें';
  @override
  String get security_changeTxnPinSub => 'भुगतान के लिए 6-अंकीय MPIN';
  @override
  String get security_txnLimits => 'लेन-देन सीमाएँ';
  @override
  String get security_txnLimitsSub => 'दैनिक: ₹1,00,000 प्रति लेन-देन';
  @override
  String get security_sectionApp => 'ऐप सुरक्षा';
  @override
  String get security_appLock => 'ऐप लॉक';
  @override
  String get security_appLockSub => 'न्यूनीकृत होने पर ऐप लॉक करें';
  @override
  String get security_loginAlerts => 'लॉगिन अलर्ट';
  @override
  String get security_loginAlertsSub => 'नए साइन-इन पर सूचित करें';
  @override
  String get security_blockedMerchants => 'अवरुद्ध व्यापारी';
  @override
  String get security_blockedMerchantsSub => 'अवरुद्ध श्रेणियाँ प्रबंधित करें';
  @override
  String get common_cancel => 'रद्द करें';
  @override
  String get common_confirm => 'पुष्टि करें';
  @override
  String get common_save => 'सहेजें';
  @override
  String get common_enable => 'सक्षम करें';
  @override
  String get common_logOut => 'लॉग आउट';
  @override
  String get common_appVersion => 'ProFinch v1.0.0  •  बिल्ड 100';
  

}

// ─────────────────────────────────────────────────────────────────────────────
//  Kannada (ಕನ್ನಡ)
// ─────────────────────────────────────────────────────────────────────────────
class _KnStrings extends _Strings {
  @override
  String get dashboard_welcomeBack => 'ಮರಳಿ ಸ್ವಾಗತ';
  @override
  String get dashboard_totalBalance => 'ಒಟ್ಟು ಬ್ಯಾಲೆನ್ಸ್';
  @override
  String get dashboard_send => 'ಕಳುಹಿಸಿ';
  @override
  String get dashboard_addMoney => 'ಹಣ ಸೇರಿಸಿ';
  @override
  String get dashboard_scan => 'ಸ್ಕ್ಯಾನ್';
  @override
  String get dashboard_wallet => 'ವಾಲೆಟ್';
  @override
  String get dashboard_quickAccess => 'ತ್ವರಿತ ಪ್ರವೇಶ';
  @override
  String get dashboard_recentTx => 'ಇತ್ತೀಚಿನ ವ್ಯವಹಾರಗಳು';
  @override
  String get dashboard_seeAll => 'ಎಲ್ಲ ನೋಡಿ';
  @override
  String get dashboard_edit => 'ಸಂಪಾದಿಸಿ';
  @override
  String get nav_home => 'ಮುಖಪುಟ';
  @override
  String get nav_transactions => 'ವ್ಯವಹಾರಗಳು';
  @override
  String get nav_scan => 'ಸ್ಕ್ಯಾನ್';
  @override
  String get nav_offers => 'ಆಫರ್‌ಗಳು';
  @override
  String get nav_profile => 'ಪ್ರೊಫೈಲ್';
  @override
  String get qa_accounts => 'ಖಾತೆಗಳು';
  @override
  String get qa_cards => 'ಕಾರ್ಡ್‌ಗಳು';
  @override
  String get qa_loans => 'ಸಾಲಗಳು';
  @override
  String get qa_analytics => 'ವಿಶ್ಲೇಷಣೆ';
  @override
  String get qa_bills => 'ಬಿಲ್‌ಗಳು';
  @override
  String get qa_rewards => 'ಪ್ರಶಸ್ತಿಗಳು';
  @override
  String get qa_more => 'ಇನ್ನಷ್ಟು';
  @override
  String get profile_title => 'ಪ್ರೊಫೈಲ್';
  @override
  String get profile_editBtn => 'ಸಂಪಾದಿಸಿ';
  @override
  String get profile_sectionPersonal => 'ವೈಯಕ್ತಿಕ ಮಾಹಿತಿ';
  @override
  String get profile_sectionSecurity => 'ಖಾತೆ ಮತ್ತು ಭದ್ರತೆ';
  @override
  String get profile_sectionPrefs => 'ಆದ್ಯತೆಗಳು';
  @override
  String get profile_sectionSupport => 'ಬೆಂಬಲ ಮತ್ತು ಕಾನೂನು';
  @override
  String get profile_phone => 'ಫೋನ್ ಸಂಖ್ಯೆ';
  @override
  String get profile_pan => 'ಪ್ಯಾನ್ ಸಂಖ್ಯೆ';
  @override
  String get profile_primaryAccount => 'ಮುಖ್ಯ ಖಾತೆ';
  @override
  String get profile_memberSince => 'ಸದಸ್ಯರಾದ ದಿನಾಂಕ';
  @override
  String get profile_security => 'ಭದ್ರತಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';
  @override
  String get profile_securitySub => 'ಪಿನ್, ಬಯೋಮೆಟ್ರಿಕ್ಸ್, 2FA';
  @override
  String get profile_linkedDevices => 'ಲಿಂಕ್ ಮಾಡಿದ ಸಾಧನಗಳು';
  @override
  String get profile_linkedDevicesSub => '2 ಸಾಧನಗಳು ಸಕ್ರಿಯ';
  @override
  String get profile_loginActivity => 'ಲಾಗಿನ್ ಚಟುವಟಿಕೆ';
  @override
  String get profile_loginActivitySub => 'ಕೊನೆಯ ಲಾಗಿನ್: ಇಂದು 9:41 AM';
  @override
  String get profile_notifications => 'ಅಧಿಸೂಚನೆಗಳು';
  @override
  String get profile_notifSub => 'ಎಚ್ಚರಿಕೆಗಳು, SMS, ಇಮೇಲ್';
  @override
  String get profile_language => 'ಭಾಷೆ';
  @override
  String get profile_langSub => 'ಕನ್ನಡ';
  @override
  String get profile_statement => 'ಹೇಳಿಕೆ ಆದ್ಯತೆಗಳು';
  @override
  String get profile_statementSub => 'ಡಿಜಿಟಲ್ — ಇಮೇಲ್‌ಗೆ';
  @override
  String get profile_help => 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ';
  @override
  String get profile_helpSub => 'FAQ, ಚಾಟ್, ಕರೆ ಮಾಡಿ';
  @override
  String get profile_privacy => 'ಗೌಪ್ಯತಾ ನೀತಿ';
  @override
  String get profile_privacySub => 'ಕೊನೆಯ ನವೀಕರಣ ಜನವರಿ 2025';
  @override
  String get profile_terms => 'ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳು';
  @override
  String get profile_termsSub => 'ಬಳಕೆದಾರ ಒಪ್ಪಂದ';
  @override
  String get profile_rate => 'ಅಪ್ಲಿಕೇಶನ್ ರೇಟ್ ಮಾಡಿ';
  @override
  String get profile_rateSub => 'ನಿಮ್ಮ ಅಭಿಪ್ರಾಯ ಹಂಚಿಕೊಳ್ಳಿ';
  @override
  String get profile_logout => 'ಲಾಗ್ ಔಟ್';
  @override
  String get profile_kycVerified => 'KYC ಪರಿಶೀಲಿಸಲಾಗಿದೆ';
  @override
  String get profile_kycPending => 'KYC ಬಾಕಿ ಇದೆ';
  @override
  String get profile_verified => 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ';
  @override
  String get editProfile_title => 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ';
  @override
  String get editProfile_changePhoto => 'ಫೋಟೋ ಬದಲಾಯಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ';
  @override
  String get editProfile_sectionPersonal => 'ವೈಯಕ್ತಿಕ ವಿವರಗಳು';
  @override
  String get editProfile_sectionAccount => 'ಮುಖ್ಯ ಖಾತೆ';
  @override
  String get editProfile_fullName => 'ಪೂರ್ಣ ಹೆಸರು';
  @override
  String get editProfile_email => 'ಇಮೇಲ್ ವಿಳಾಸ';
  @override
  String get editProfile_phone => 'ಫೋನ್ ಸಂಖ್ಯೆ';
  @override
  String get editProfile_selectAccount => 'ಮುಖ್ಯ ಖಾತೆ ಆಯ್ಕೆ ಮಾಡಿ';
  @override
  String get editProfile_saveBtn => 'ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ';
  @override
  String get editProfile_successMsg => 'ಪ್ರೊಫೈಲ್ ಯಶಸ್ವಿಯಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ';
  @override
  String get editProfile_infoNote =>
      'ನಿಮ್ಮ ಮುಖ್ಯ ಖಾತೆಯನ್ನು ವೇತನ ಕ್ರೆಡಿಟ್‌ಗೆ ಬಳಸಲಾಗುತ್ತದೆ.';
  @override
  String get editProfile_errNameEmpty => 'ಹೆಸರು ಖಾಲಿ ಇರಬಾರದು';
  @override
  String get editProfile_errEmailEmpty => 'ಇಮೇಲ್ ಖಾಲಿ ಇರಬಾರದು';
  @override
  String get editProfile_errEmailInvalid => 'ಮಾನ್ಯ ಇಮೇಲ್ ವಿಳಾಸ ನಮೂದಿಸಿ';
  @override
  String get editProfile_errPhoneEmpty => 'ಫೋನ್ ಸಂಖ್ಯೆ ಖಾಲಿ ಇರಬಾರದು';
  @override
  String get editProfile_errPhoneShort => '10 ಅಂಕಿಯ ಮಾನ್ಯ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ';
  @override
  String get security_title => 'ಭದ್ರತಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';
  @override
  String get security_scoreLabel => 'ಭದ್ರತಾ ಸ್ಕೋರ್';
  @override
  String get security_scoreHint => 'ಉತ್ತಮ — 2FA ಸಕ್ರಿಯಗೊಳಿಸಿ';
  @override
  String get security_sectionAuth => 'ದೃಢೀಕರಣ';
  @override
  String get security_biometric => 'ಬಯೋಮೆಟ್ರಿಕ್ ಲಾಗಿನ್';
  @override
  String get security_biometricSub => 'ಫಿಂಗರ್‌ಪ್ರಿಂಟ್ ಅಥವಾ Face ID ಬಳಸಿ';
  @override
  String get security_twoFa => 'ದ್ವಿ-ಅಂಶ ದೃಢೀಕರಣ';
  @override
  String get security_twoFaSub => 'ನೋಂದಾಯಿತ ಮೊಬೈಲ್‌ಗೆ OTP';
  @override
  String get security_changeLoginPin => 'ಲಾಗಿನ್ PIN ಬದಲಾಯಿಸಿ';
  @override
  String get security_changeLoginPinSub => '4-ಅಂಕಿ ಲಾಗಿನ್ PIN';
  @override
  String get security_sectionTxn => 'ವ್ಯವಹಾರ ಭದ್ರತೆ';
  @override
  String get security_txnPin => 'ವ್ಯವಹಾರ PIN';
  @override
  String get security_txnPinSub => 'ಪ್ರತಿ ವರ್ಗಾವಣೆಗೆ ಅಗತ್ಯ';
  @override
  String get security_changeTxnPin => 'ವ್ಯವಹಾರ PIN ಬದಲಾಯಿಸಿ';
  @override
  String get security_changeTxnPinSub => '6-ಅಂಕಿ MPIN';
  @override
  String get security_txnLimits => 'ವ್ಯವಹಾರ ಮಿತಿಗಳು';
  @override
  String get security_txnLimitsSub => 'ದೈನಂದಿನ: ₹1,00,000';
  @override
  String get security_sectionApp => 'ಅಪ್ಲಿಕೇಶನ್ ಭದ್ರತೆ';
  @override
  String get security_appLock => 'ಅಪ್ಲಿಕೇಶನ್ ಲಾಕ್';
  @override
  String get security_appLockSub => 'ಮಿನಿಮೈಸ್ ಮಾಡಿದಾಗ ಲಾಕ್';
  @override
  String get security_loginAlerts => 'ಲಾಗಿನ್ ಎಚ್ಚರಿಕೆಗಳು';
  @override
  String get security_loginAlertsSub => 'ಹೊಸ ಸೈನ್-ಇನ್‌ಗೆ ಸೂಚಿಸಿ';
  @override
  String get security_blockedMerchants => 'ನಿರ್ಬಂಧಿತ ವ್ಯಾಪಾರಿಗಳು';
  @override
  String get security_blockedMerchantsSub => 'ನಿರ್ಬಂಧಿತ ವರ್ಗಗಳನ್ನು ನಿರ್ವಹಿಸಿ';
  @override
  String get common_cancel => 'ರದ್ದು ಮಾಡಿ';
  @override
  String get common_confirm => 'ದೃಢೀಕರಿಸಿ';
  @override
  String get common_save => 'ಉಳಿಸಿ';
  @override
  String get common_enable => 'ಸಕ್ರಿಯಗೊಳಿಸಿ';
  @override
  String get common_logOut => 'ಲಾಗ್ ಔಟ್';
  @override
  String get common_appVersion => 'ProFinch v1.0.0  •  ಬಿಲ್ಡ್ 100';
  
  @override
  String get qa_beneficiary => 'ಲಾಭದಾತ';
  
  @override
  String get qa_calculators => 'ಲಾಭದಾತ';
  
  @override
  String get qa_insurance => 'ಲಾಭದಾತ';
  
  @override
  String get qa_invest => 'ಲಾಭದಾತ';
  
  @override
  String get qa_termDeposit => 'ಲಾಭದಾತ';
  
  @override
  String get qa_Less => 'ಕಡಿಮೆ';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Tamil (தமிழ்)
// ─────────────────────────────────────────────────────────────────────────────
class _TaStrings extends _Strings {
  @override
  String get dashboard_welcomeBack => 'மீண்டும் வரவேற்கிறோம்';
  @override
  String get dashboard_totalBalance => 'மொத்த இருப்பு';
  @override
  String get dashboard_send => 'அனுப்பு';
  @override
  String get dashboard_addMoney => 'பணம் சேர்';
  @override
  String get dashboard_scan => 'ஸ்கேன்';
  @override
  String get dashboard_wallet => 'வாலட்';
  @override
  String get dashboard_quickAccess => 'விரைவு அணுகல்';
  @override
  String get dashboard_recentTx => 'சமீபத்திய பரிவர்த்தனைகள்';
  @override
  String get dashboard_seeAll => 'அனைத்தையும் காண்க';
  @override
  String get dashboard_edit => 'திருத்து';
  @override
  String get nav_home => 'முகப்பு';
  @override
  String get nav_transactions => 'பரிவர்த்தனைகள்';
  @override
  String get nav_scan => 'ஸ்கேன்';
  @override
  String get nav_offers => 'சலுகைகள்';
  @override
  String get nav_profile => 'சுயவிவரம்';
  @override
  String get qa_accounts => 'கணக்குகள்';
  @override
  String get qa_cards => 'அட்டைகள்';
  @override
  String get qa_loans => 'கடன்கள்';
  @override
  String get qa_analytics => 'பகுப்பாய்வு';
  @override
  String get qa_bills => 'பில்கள்';
  @override
  String get qa_rewards => 'வெகுமதிகள்';
  @override
  String get qa_more => 'மேலும்';
  @override
  String get profile_title => 'சுயவிவரம்';
  @override
  String get profile_editBtn => 'திருத்து';
  @override
  String get profile_sectionPersonal => 'தனிப்பட்ட தகவல்';
  @override
  String get profile_sectionSecurity => 'கணக்கு & பாதுகாப்பு';
  @override
  String get profile_sectionPrefs => 'விருப்பங்கள்';
  @override
  String get profile_sectionSupport => 'ஆதரவு & சட்டம்';
  @override
  String get profile_phone => 'தொலைபேசி எண்';
  @override
  String get profile_pan => 'பான் எண்';
  @override
  String get profile_primaryAccount => 'முதன்மை கணக்கு';
  @override
  String get profile_memberSince => 'உறுப்பினர் தொடக்கம்';
  @override
  String get profile_security => 'பாதுகாப்பு அமைப்புகள்';
  @override
  String get profile_securitySub => 'பின், பயோமெட்ரிக்ஸ், 2FA';
  @override
  String get profile_linkedDevices => 'இணைக்கப்பட்ட சாதனங்கள்';
  @override
  String get profile_linkedDevicesSub => '2 சாதனங்கள் செயலில்';
  @override
  String get profile_loginActivity => 'உள்நுழைவு செயல்பாடு';
  @override
  String get profile_loginActivitySub => 'கடைசி உள்நுழைவு: இன்று 9:41 AM';
  @override
  String get profile_notifications => 'அறிவிப்புகள்';
  @override
  String get profile_notifSub => 'எச்சரிக்கைகள், SMS, மின்னஞ்சல்';
  @override
  String get profile_language => 'மொழி';
  @override
  String get profile_langSub => 'தமிழ்';
  @override
  String get profile_statement => 'அறிக்கை விருப்பங்கள்';
  @override
  String get profile_statementSub => 'டிஜிட்டல் — மின்னஞ்சலுக்கு';
  @override
  String get profile_help => 'உதவி & ஆதரவு';
  @override
  String get profile_helpSub => 'FAQ, அரட்டை, அழைப்பு';
  @override
  String get profile_privacy => 'தனியுரிமை கொள்கை';
  @override
  String get profile_privacySub => 'கடைசி புதுப்பிப்பு ஜன 2025';
  @override
  String get profile_terms => 'விதிமுறைகள் & நிபந்தனைகள்';
  @override
  String get profile_termsSub => 'பயனர் ஒப்பந்தம்';
  @override
  String get profile_rate => 'பயன்பாட்டை மதிப்பிடுங்கள்';
  @override
  String get profile_rateSub => 'உங்கள் கருத்தை பகிருங்கள்';
  @override
  String get profile_logout => 'வெளியேறு';
  @override
  String get profile_kycVerified => 'KYC சரிபார்க்கப்பட்டது';
  @override
  String get profile_kycPending => 'KYC நிலுவையில்';
  @override
  String get profile_verified => 'சரிபார்க்கப்பட்டது';
  @override
  String get editProfile_title => 'சுயவிவரம் திருத்து';
  @override
  String get editProfile_changePhoto => 'புகைப்படம் மாற்ற தட்டுங்கள்';
  @override
  String get editProfile_sectionPersonal => 'தனிப்பட்ட விவரங்கள்';
  @override
  String get editProfile_sectionAccount => 'முதன்மை கணக்கு';
  @override
  String get editProfile_fullName => 'முழு பெயர்';
  @override
  String get editProfile_email => 'மின்னஞ்சல் முகவரி';
  @override
  String get editProfile_phone => 'தொலைபேசி எண்';
  @override
  String get editProfile_selectAccount => 'முதன்மை கணக்கை தேர்ந்தெடுக்கவும்';
  @override
  String get editProfile_saveBtn => 'மாற்றங்களை சேமி';
  @override
  String get editProfile_successMsg =>
      'சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது';
  @override
  String get editProfile_infoNote =>
      'உங்கள் முதன்மை கணக்கு சம்பள கடன் மற்றும் இயல்புநிலை பரிவர்த்தனைகளுக்கு பயன்படுத்தப்படுகிறது.';
  @override
  String get editProfile_errNameEmpty => 'பெயர் காலியாக இருக்கக்கூடாது';
  @override
  String get editProfile_errEmailEmpty => 'மின்னஞ்சல் காலியாக இருக்கக்கூடாது';
  @override
  String get editProfile_errEmailInvalid =>
      'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்';
  @override
  String get editProfile_errPhoneEmpty => 'தொலைபேசி காலியாக இருக்கக்கூடாது';
  @override
  String get editProfile_errPhoneShort => 'சரியான 10-இலக்க எண்ணை உள்ளிடவும்';
  @override
  String get security_title => 'பாதுகாப்பு அமைப்புகள்';
  @override
  String get security_scoreLabel => 'பாதுகாப்பு மதிப்பெண்';
  @override
  String get security_scoreHint => 'நல்லது — 2FA இயக்குங்கள்';
  @override
  String get security_sectionAuth => 'அங்கீகாரம்';
  @override
  String get security_biometric => 'பயோமெட்ரிக் உள்நுழைவு';
  @override
  String get security_biometricSub => 'கைரேகை அல்லது Face ID';
  @override
  String get security_twoFa => 'இரு-காரணி அங்கீகாரம்';
  @override
  String get security_twoFaSub => 'பதிவு செய்யப்பட்ட மொபைலுக்கு OTP';
  @override
  String get security_changeLoginPin => 'உள்நுழைவு PIN மாற்று';
  @override
  String get security_changeLoginPinSub => '4-இலக்க உள்நுழைவு PIN';
  @override
  String get security_sectionTxn => 'பரிவர்த்தனை பாதுகாப்பு';
  @override
  String get security_txnPin => 'பரிவர்த்தனை PIN';
  @override
  String get security_txnPinSub => 'ஒவ்வொரு பரிமாற்றத்திற்கும் தேவை';
  @override
  String get security_changeTxnPin => 'பரிவர்த்தனை PIN மாற்று';
  @override
  String get security_changeTxnPinSub => '6-இலக்க MPIN';
  @override
  String get security_txnLimits => 'பரிவர்த்தனை வரம்புகள்';
  @override
  String get security_txnLimitsSub => 'தினசரி: ₹1,00,000';
  @override
  String get security_sectionApp => 'பயன்பாட்டு பாதுகாப்பு';
  @override
  String get security_appLock => 'பயன்பாட்டு பூட்டு';
  @override
  String get security_appLockSub => 'சிறிதாக்கும்போது பூட்டு';
  @override
  String get security_loginAlerts => 'உள்நுழைவு எச்சரிக்கைகள்';
  @override
  String get security_loginAlertsSub => 'புதிய உள்நுழைவில் அறிவிக்கவும்';
  @override
  String get security_blockedMerchants => 'தடுக்கப்பட்ட வணிகர்கள்';
  @override
  String get security_blockedMerchantsSub =>
      'தடுக்கப்பட்ட வகைகளை நிர்வகிக்கவும்';
  @override
  String get common_cancel => 'ரத்து செய்';
  @override
  String get common_confirm => 'உறுதிப்படுத்து';
  @override
  String get common_save => 'சேமி';
  @override
  String get common_enable => 'இயக்கு';
  @override
  String get common_logOut => 'வெளியேறு';
  @override
  String get common_appVersion => 'ProFinch v1.0.0  •  பில்ட் 100';
  
  @override
  String get qa_beneficiary => 'பயனாளி';
  
  @override
  String get qa_calculators => 'பயனாளி';
  
  @override
  String get qa_insurance => 'பயனாளி';
  
  @override
  String get qa_invest => 'பயனாளி';
  
  @override
  String get qa_termDeposit => 'பயனாளி';
  
  @override
  String get qa_Less => 'குறைவு';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Telugu (తెలుగు)
// ─────────────────────────────────────────────────────────────────────────────
class _TeStrings extends _Strings {
  @override
  String get dashboard_welcomeBack => 'తిరిగి స్వాగతం';
  @override
  String get dashboard_totalBalance => 'మొత్తం బ్యాలెన్స్';
  @override
  String get dashboard_send => 'పంపు';
  @override
  String get dashboard_addMoney => 'డబ్బు జోడించు';
  @override
  String get dashboard_scan => 'స్కాన్';
  @override
  String get dashboard_wallet => 'వాలెట్';
  @override
  String get dashboard_quickAccess => 'శీఘ్ర ప్రవేశం';
  @override
  String get dashboard_recentTx => 'ఇటీవలి లావాదేవీలు';
  @override
  String get dashboard_seeAll => 'అన్నీ చూడు';
  @override
  String get dashboard_edit => 'సవరించు';
  @override
  String get nav_home => 'హోమ్';
  @override
  String get nav_transactions => 'లావాదేవీలు';
  @override
  String get nav_scan => 'స్కాన్';
  @override
  String get nav_offers => 'ఆఫర్లు';
  @override
  String get nav_profile => 'ప్రొఫైల్';
  @override
  String get qa_accounts => 'ఖాతాలు';
  @override
  String get qa_cards => 'కార్డులు';
  @override
  String get qa_loans => 'రుణాలు';
  @override
  String get qa_analytics => 'విశ్లేషణ';
  @override
  String get qa_bills => 'బిల్లులు';
  @override
  String get qa_rewards => 'బహుమతులు';
  @override
  String get qa_more => 'మరిన్ని';
  @override
  String get profile_title => 'ప్రొఫైల్';
  @override
  String get profile_editBtn => 'సవరించు';
  @override
  String get profile_sectionPersonal => 'వ్యక్తిగత సమాచారం';
  @override
  String get profile_sectionSecurity => 'ఖాతా & భద్రత';
  @override
  String get profile_sectionPrefs => 'ప్రాధాన్యతలు';
  @override
  String get profile_sectionSupport => 'మద్దతు & చట్టపరమైన';
  @override
  String get profile_phone => 'ఫోన్ నంబర్';
  @override
  String get profile_pan => 'పాన్ నంబర్';
  @override
  String get profile_primaryAccount => 'ప్రాథమిక ఖాతా';
  @override
  String get profile_memberSince => 'సభ్యుడైన తేదీ';
  @override
  String get profile_security => 'భద్రతా సెట్టింగులు';
  @override
  String get profile_securitySub => 'పిన్, బయోమెట్రిక్స్, 2FA';
  @override
  String get profile_linkedDevices => 'లింక్ చేయబడిన పరికరాలు';
  @override
  String get profile_linkedDevicesSub => '2 పరికరాలు సక్రియంగా ఉన్నాయి';
  @override
  String get profile_loginActivity => 'లాగిన్ కార్యకలాపం';
  @override
  String get profile_loginActivitySub => 'చివరి లాగిన్: ఈరోజు 9:41 AM';
  @override
  String get profile_notifications => 'నోటిఫికేషన్లు';
  @override
  String get profile_notifSub => 'హెచ్చరికలు, SMS, ఇమెయిల్';
  @override
  String get profile_language => 'భాష';
  @override
  String get profile_langSub => 'తెలుగు';
  @override
  String get profile_statement => 'స్టేట్‌మెంట్ ప్రాధాన్యతలు';
  @override
  String get profile_statementSub => 'డిజిటల్ — ఇమెయిల్‌కు';
  @override
  String get profile_help => 'సహాయం & మద్దతు';
  @override
  String get profile_helpSub => 'FAQ, చాట్, కాల్ చేయండి';
  @override
  String get profile_privacy => 'గోప్యతా విధానం';
  @override
  String get profile_privacySub => 'చివరి నవీకరణ జన 2025';
  @override
  String get profile_terms => 'నిబంధనలు & షరతులు';
  @override
  String get profile_termsSub => 'వినియోగదారు ఒప్పందం';
  @override
  String get profile_rate => 'యాప్‌ను రేట్ చేయండి';
  @override
  String get profile_rateSub => 'మీ అభిప్రాయాన్ని పంచుకోండి';
  @override
  String get profile_logout => 'లాగ్ అవుట్';
  @override
  String get profile_kycVerified => 'KYC ధృవీకరించబడింది';
  @override
  String get profile_kycPending => 'KYC పెండింగ్‌లో ఉంది';
  @override
  String get profile_verified => 'ధృవీకరించబడింది';
  @override
  String get editProfile_title => 'ప్రొఫైల్ సవరించు';
  @override
  String get editProfile_changePhoto => 'ఫోటో మార్చడానికి నొక్కండి';
  @override
  String get editProfile_sectionPersonal => 'వ్యక్తిగత వివరాలు';
  @override
  String get editProfile_sectionAccount => 'ప్రాథమిక ఖాతా';
  @override
  String get editProfile_fullName => 'పూర్తి పేరు';
  @override
  String get editProfile_email => 'ఇమెయిల్ చిరునామా';
  @override
  String get editProfile_phone => 'ఫోన్ నంబర్';
  @override
  String get editProfile_selectAccount => 'ప్రాథమిక ఖాతా ఎంచుకోండి';
  @override
  String get editProfile_saveBtn => 'మార్పులు సేవ్ చేయి';
  @override
  String get editProfile_successMsg => 'ప్రొఫైల్ విజయవంతంగా నవీకరించబడింది';
  @override
  String get editProfile_infoNote =>
      'మీ ప్రాథమిక ఖాతా జీతం క్రెడిట్ మరియు డిఫాల్ట్ లావాదేవీలకు ఉపయోగించబడుతుంది.';
  @override
  String get editProfile_errNameEmpty => 'పేరు ఖాళీగా ఉండకూడదు';
  @override
  String get editProfile_errEmailEmpty => 'ఇమెయిల్ ఖాళీగా ఉండకూడదు';
  @override
  String get editProfile_errEmailInvalid =>
      'చెల్లుబాటు అయ్యే ఇమెయిల్ చిరునామా నమోదు చేయండి';
  @override
  String get editProfile_errPhoneEmpty => 'ఫోన్ నంబర్ ఖాళీగా ఉండకూడదు';
  @override
  String get editProfile_errPhoneShort =>
      'చెల్లుబాటు అయ్యే 10-అంకెల నంబర్ నమోదు చేయండి';
  @override
  String get security_title => 'భద్రతా సెట్టింగులు';
  @override
  String get security_scoreLabel => 'భద్రతా స్కోర్';
  @override
  String get security_scoreHint => 'మంచిది — 2FA ప్రారంభించండి';
  @override
  String get security_sectionAuth => 'ప్రమాణీకరణ';
  @override
  String get security_biometric => 'బయోమెట్రిక్ లాగిన్';
  @override
  String get security_biometricSub => 'వేలిముద్ర లేదా Face ID ఉపయోగించండి';
  @override
  String get security_twoFa => 'రెండు-కారక ప్రమాణీకరణ';
  @override
  String get security_twoFaSub => 'నమోదైన మొబైల్‌కు OTP';
  @override
  String get security_changeLoginPin => 'లాగిన్ PIN మార్చు';
  @override
  String get security_changeLoginPinSub => '4-అంకె లాగిన్ PIN';
  @override
  String get security_sectionTxn => 'లావాదేవీ భద్రత';
  @override
  String get security_txnPin => 'లావాదేవీ PIN';
  @override
  String get security_txnPinSub => 'ప్రతి బదిలీకి అవసరం';
  @override
  String get security_changeTxnPin => 'లావాదేవీ PIN మార్చు';
  @override
  String get security_changeTxnPinSub => '6-అంకె MPIN';
  @override
  String get security_txnLimits => 'లావాదేవీ పరిమితులు';
  @override
  String get security_txnLimitsSub => 'రోజువారీ: ₹1,00,000';
  @override
  String get security_sectionApp => 'యాప్ భద్రత';
  @override
  String get security_appLock => 'యాప్ లాక్';
  @override
  String get security_appLockSub => 'తగ్గించినప్పుడు లాక్ చేయి';
  @override
  String get security_loginAlerts => 'లాగిన్ హెచ్చరికలు';
  @override
  String get security_loginAlertsSub => 'కొత్త సైన్-ఇన్‌పై తెలియజేయి';
  @override
  String get security_blockedMerchants => 'బ్లాక్ చేయబడిన వ్యాపారులు';
  @override
  String get security_blockedMerchantsSub =>
      'బ్లాక్ చేయబడిన వర్గాలను నిర్వహించండి';
  @override
  String get common_cancel => 'రద్దు చేయి';
  @override
  String get common_confirm => 'నిర్ధారించు';
  @override
  String get common_save => 'సేవ్ చేయి';
  @override
  String get common_enable => 'ప్రారంభించు';
  @override
  String get common_logOut => 'లాగ్ అవుట్';
  @override
  String get common_appVersion => 'ProFinch v1.0.0  •  బిల్డ్ 100';
  
  @override
  String get qa_beneficiary => 'లాభదారు';
  
  @override
  String get qa_calculators => 'లాభదారు';
  
  @override
  
  String get qa_insurance => 'లాభదారు';
  
  @override
  
  String get qa_invest => 'లాభదారు';
  
  @override
  
  String get qa_termDeposit => 'లాభదారు';
  
  @override
  String get qa_Less => 'తక్కువ';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Marathi (मराठी)
// ─────────────────────────────────────────────────────────────────────────────
class _MrStrings extends _Strings {
  @override
  String get dashboard_welcomeBack => 'परत स्वागत आहे';
  @override
  String get dashboard_totalBalance => 'एकूण शिल्लक';
  @override
  String get dashboard_send => 'पाठवा';
  @override
  String get dashboard_addMoney => 'पैसे जोडा';
  @override
  String get dashboard_scan => 'स्कॅन';
  @override
  String get dashboard_wallet => 'वॉलेट';
  @override
  String get dashboard_quickAccess => 'द्रुत प्रवेश';
  @override
  String get dashboard_recentTx => 'अलीकडील व्यवहार';
  @override
  String get dashboard_seeAll => 'सर्व पहा';
  @override
  String get dashboard_edit => 'संपादन करा';
  @override
  String get nav_home => 'मुख्यपृष्ठ';
  @override
  String get nav_transactions => 'व्यवहार';
  @override
  String get nav_scan => 'स्कॅन';
  @override
  String get nav_offers => 'ऑफर';
  @override
  String get nav_profile => 'प्रोफाइल';
  @override
  String get qa_accounts => 'खाती';
  @override
  String get qa_cards => 'कार्डे';
  @override
  String get qa_loans => 'कर्जे';
  @override
  String get qa_analytics => 'विश्लेषण';
  @override
  String get qa_bills => 'बिले';
  @override
  String get qa_rewards => 'बक्षिसे';
  @override
  String get qa_more => 'आणखी';
  @override
  String get profile_title => 'प्रोफाइल';
  @override
  String get profile_editBtn => 'संपादन करा';
  @override
  String get profile_sectionPersonal => 'वैयक्तिक माहिती';
  @override
  String get profile_sectionSecurity => 'खाते आणि सुरक्षा';
  @override
  String get profile_sectionPrefs => 'प्राधान्ये';
  @override
  String get profile_sectionSupport => 'सहाय्य आणि कायदेशीर';
  @override
  String get profile_phone => 'फोन नंबर';
  @override
  String get profile_pan => 'पॅन नंबर';
  @override
  String get profile_primaryAccount => 'प्राथमिक खाते';
  @override
  String get profile_memberSince => 'सदस्यता दिनांक';
  @override
  String get profile_security => 'सुरक्षा सेटिंग्ज';
  @override
  String get profile_securitySub => 'पिन, बायोमेट्रिक्स, 2FA';
  @override
  String get profile_linkedDevices => 'जोडलेली उपकरणे';
  @override
  String get profile_linkedDevicesSub => '2 उपकरणे सक्रिय';
  @override
  String get profile_loginActivity => 'लॉगिन क्रियाकलाप';
  @override
  String get profile_loginActivitySub => 'शेवटचे लॉगिन: आज, 9:41 AM';
  @override
  String get profile_notifications => 'सूचना';
  @override
  String get profile_notifSub => 'अलर्ट, SMS, ईमेल';
  @override
  String get profile_language => 'भाषा';
  @override
  String get profile_langSub => 'मराठी';
  @override
  String get profile_statement => 'विवरण प्राधान्ये';
  @override
  String get profile_statementSub => 'डिजिटल — ईमेलवर';
  @override
  String get profile_help => 'मदत आणि सहाय्य';
  @override
  String get profile_helpSub => 'FAQ, चॅट, कॉल करा';
  @override
  String get profile_privacy => 'गोपनीयता धोरण';
  @override
  String get profile_privacySub => 'शेवटचे अद्यतन जाने 2025';
  @override
  String get profile_terms => 'अटी आणि शर्ती';
  @override
  String get profile_termsSub => 'वापरकर्ता करार';
  @override
  String get profile_rate => 'ॲपला रेटिंग द्या';
  @override
  String get profile_rateSub => 'आपला अभिप्राय सामायिक करा';
  @override
  String get profile_logout => 'लॉग आउट';
  @override
  String get profile_kycVerified => 'KYC सत्यापित';
  @override
  String get profile_kycPending => 'KYC प्रलंबित';
  @override
  String get profile_verified => 'सत्यापित';
  @override
  String get editProfile_title => 'प्रोफाइल संपादित करा';
  @override
  String get editProfile_changePhoto => 'फोटो बदलण्यासाठी टॅप करा';
  @override
  String get editProfile_sectionPersonal => 'वैयक्तिक तपशील';
  @override
  String get editProfile_sectionAccount => 'प्राथमिक खाते';
  @override
  String get editProfile_fullName => 'पूर्ण नाव';
  @override
  String get editProfile_email => 'ईमेल पत्ता';
  @override
  String get editProfile_phone => 'फोन नंबर';
  @override
  String get editProfile_selectAccount => 'प्राथमिक खाते निवडा';
  @override
  String get editProfile_saveBtn => 'बदल जतन करा';
  @override
  String get editProfile_successMsg => 'प्रोफाइल यशस्वीरित्या अद्यतनित केले';
  @override
  String get editProfile_infoNote =>
      'तुमचे प्राथमिक खाते वेतन क्रेडिट आणि डीफॉल्ट व्यवहारांसाठी वापरले जाते.';
  @override
  String get editProfile_errNameEmpty => 'नाव रिकामे असू शकत नाही';
  @override
  String get editProfile_errEmailEmpty => 'ईमेल रिकामे असू शकत नाही';
  @override
  String get editProfile_errEmailInvalid => 'वैध ईमेल पत्ता प्रविष्ट करा';
  @override
  String get editProfile_errPhoneEmpty => 'फोन रिकामे असू शकत नाही';
  @override
  String get editProfile_errPhoneShort => 'वैध 10 अंकी नंबर प्रविष्ट करा';
  @override
  String get security_title => 'सुरक्षा सेटिंग्ज';
  @override
  String get security_scoreLabel => 'सुरक्षा गुण';
  @override
  String get security_scoreHint => 'चांगले — 2FA सक्षम करा';
  @override
  String get security_sectionAuth => 'प्रमाणीकरण';
  @override
  String get security_biometric => 'बायोमेट्रिक लॉगिन';
  @override
  String get security_biometricSub => 'फिंगरप्रिंट किंवा Face ID वापरा';
  @override
  String get security_twoFa => 'द्वि-घटक प्रमाणीकरण';
  @override
  String get security_twoFaSub => 'नोंदणीकृत मोबाईलवर OTP';
  @override
  String get security_changeLoginPin => 'लॉगिन PIN बदला';
  @override
  String get security_changeLoginPinSub => '4-अंकी लॉगिन PIN';
  @override
  String get security_sectionTxn => 'व्यवहार सुरक्षा';
  @override
  String get security_txnPin => 'व्यवहार PIN';
  @override
  String get security_txnPinSub => 'प्रत्येक हस्तांतरणासाठी आवश्यक';
  @override
  String get security_changeTxnPin => 'व्यवहार PIN बदला';
  @override
  String get security_changeTxnPinSub => '6-अंकी MPIN';
  @override
  String get security_txnLimits => 'व्यवहार मर्यादा';
  @override
  String get security_txnLimitsSub => 'दैनिक: ₹1,00,000';
  @override
  String get security_sectionApp => 'ॲप सुरक्षा';
  @override
  String get security_appLock => 'ॲप लॉक';
  @override
  String get security_appLockSub => 'कमी केल्यावर लॉक करा';
  @override
  String get security_loginAlerts => 'लॉगिन अलर्ट';
  @override
  String get security_loginAlertsSub => 'नवीन साइन-इनवर सूचित करा';
  @override
  String get security_blockedMerchants => 'अवरोधित व्यापारी';
  @override
  String get security_blockedMerchantsSub => 'अवरोधित श्रेणी व्यवस्थापित करा';
  @override
  String get common_cancel => 'रद्द करा';
  @override
  String get common_confirm => 'पुष्टी करा';
  @override
  String get common_save => 'जतन करा';
  @override
  String get common_enable => 'सक्षम करा';
  @override
  String get common_logOut => 'लॉग आउट';
  @override
  String get common_appVersion => 'ProFinch v1.0.0  •  बिल्ड 100';
  
  @override
  String get qa_beneficiary => 'लाभार्थी';
  
  @override
  String get qa_calculators => 'लाभार्थी';
  
  @override
  String get qa_insurance => 'लाभार्थी';
  
  @override
  String get qa_invest => 'लाभार्थी';
  
  @override
  String get qa_termDeposit => 'लाभार्थी';

  @override
  String get qa_Less => 'कमी';
}
