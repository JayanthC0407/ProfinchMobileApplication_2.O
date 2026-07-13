/// Endpoint paths lifted directly from the
/// "OBDX Mobile Banking APIs" Postman collection.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Pre-login ────────────────────────────────────────────────
  static const String rsaPublicKey = '/digx-admin/security/v1/publicKey';
  static const String salt = '/digx-admin/security/v1/salt';

  // ── Login ────────────────────────────────────────────────────
  static const String login = '/digx-infra/login/v1/login';
  static const String me = '/digx-common/user/v1/me';
  static const String anonymousToken = '/digx-infra/login/v1/anonymousToken';
  static const String logout = '/digx-infra/login/v1/logout';

  // ── Biometric ────────────────────────────────────────────────
  static const String mobileClientRegistration = '/digx-infra/mobile/v1/mobileClient';
  // NOTE: no dedicated "biometric verify/login" endpoint was present in the
  // collection — only device registration. Flag this with the backend team;
  // typically OBDX re-uses /login with x-authentication-type: BIOMETRIC or
  // similar, plus the registered secureDeviceId. Confirm before wiring #5/#6.

  // ── Forgot password / username ──────────────────────────────
  static const String forgotCredentials = '/digx-admin/sms/v1/credentials/forgotCredentials';
  static const String forgotUserId = '/digx-admin/sms/v1/credentials/forgotUserId';

  // ── Registration ─────────────────────────────────────────────
  static const String accountTypesEnum = '/digx-common/party/v1/enumerations/accountTypes';
  // NOTE: no create-user/registration submit endpoint exists in the
  // collection. Item #1 (User registration) cannot be wired yet.

  // ── Dashboard / Loan ─────────────────────────────────────────
  static const String loanList = '/digx-common/loan/v1/loan';
  static String loanById(String loanId) => '/digx-common/loan/v1/loan/$loanId';
  static String loanSchedule(String loanId) => '/digx-common/loan/v1/loan/$loanId/schedule';
  static String loanOutstanding(String loanId) => '/digx-common/loan/v1/loan/$loanId/outstanding';

  // ── CASA (Current & Savings Accounts) ───────────────────────
  static const String demandDeposit = '/digx-common/dda/v1/demandDeposit';
  static String demandDepositTransactions(String accountId) =>
      '/digx-common/dda/v1/demandDeposit/$accountId/transactions';
  static const String demandDepositMediaType = '/digx-common/dda/v1/enumerations/mediatype';
  static const String currentDate = '/digx-common/common/v1/currentDate';
}
