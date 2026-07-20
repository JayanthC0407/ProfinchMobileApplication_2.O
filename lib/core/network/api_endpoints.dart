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
  static const String mobileClientRegistration =
      '/digx-infra/mobile/v1/mobileClient';
  // NOTE: no dedicated "biometric verify/login" endpoint was present in the
  // collection — only device registration. Flag this with the backend team;
  // typically OBDX re-uses /login with x-authentication-type: BIOMETRIC or
  // similar, plus the registered secureDeviceId. Confirm before wiring #5/#6.

  // ── Forgot password / username ──────────────────────────────
  static const String forgotCredentials =
      '/digx-admin/sms/v1/credentials/forgotCredentials';
  static const String forgotUserId =
      '/digx-admin/sms/v1/credentials/forgotUserId';

  // ── Registration ─────────────────────────────────────────────
  static const String accountTypesEnum =
      '/digx-common/party/v1/enumerations/accountTypes';
  static const String registration = '/digx-common/user/v1/registration';
  static String registrationAuthentication(String registrationId) =>
      '/digx-common/user/v1/registration/$registrationId/authentication';

  // ── Dashboard / Loan ─────────────────────────────────────────
  static const String loanList = '/digx-common/loan/v1/loan';
  static String loanById(String loanId) => '/digx-common/loan/v1/loan/$loanId';
  static String loanSchedule(String loanId) =>
      '/digx-common/loan/v1/loan/$loanId/schedule';
  static String loanOutstanding(String loanId) =>
      '/digx-common/loan/v1/loan/$loanId/outstanding';

  // ── CASA (Current & Savings Accounts) ───────────────────────
  static const String demandDeposit = '/digx-common/dda/v1/demandDeposit';
  static String demandDepositTransactions(String accountId) =>
      '/digx-common/dda/v1/demandDeposit/$accountId/transactions';
  static const String demandDepositMediaType =
      '/digx-common/dda/v1/enumerations/mediatype';
  static const String currentDate = '/digx-common/common/v1/currentDate';

  // ── Profile ──────────────────────────────────────────────────
  // Fired together (in this order) whenever the Profile screen opens —
  // confirmed from the browser network tab, not the Postman collection.
  static const String partyDetails = '/digx-common/user/v1/me/party';
  static const String profileConfig = '/digx-common/user/v1/profileConfig';
  static const String countryEnum =
      '/digx-retail/origination/v1/enumerations/country';

  // ── Primary account (edit profile) ──────────────────────────
  // Same path for GET (fetch current prefs before showing the picker)
  // and PUT (save the edited prefs back) — confirmed from the browser
  // network tab, including a real GET response and PUT payload.
  static const String userPreferences = '/digx-admin/sms/v1/userPreferences';
  // ── User sessions / Login Activity ──────────────────────────
  static const String userSessions = '/digx-common/user/v1/me/sessions';

  // ── Service requests ─────────────────────────────────────────
  // Flow confirmed from the browser network tab: definitions (list) +
  // categories fire together when "Raise a new request" opens; tapping a
  // result fires definitionById + the icon's content fetch together;
  // Submit fires the POST, then a feedback-template GET (best-effort,
  // doesn't block showing the success screen).
  static const String serviceRequestDefinitions = '/digx-common/sr/v1/servicerequest/definitions';
  static String serviceRequestDefinitionById(String id) =>
      '/digx-common/sr/v1/servicerequest/definitions/$id';
  static String serviceRequestCategories(String productId) =>
      '/digx-common/sr/v1/servicerequest/products/$productId/categories';
  static const String serviceRequestSubmit = '/digx-common/sr/v1/servicerequest';
  static const String feedbackTemplate = '/digx-common/feedback/v1/feedback/template';
  // Track Request filter form: products + status enum fire together on
  // open; picking a product fires serviceRequestCategories(product)
  // (reused from above — same endpoint, driven by the picked product
  // instead of the "Raise" flow's literal "Product" placeholder); Apply
  // fires a GET on the same serviceRequestSubmit path with query params.
  static const String serviceRequestProducts = '/digx-common/sr/v1/servicerequest/products';
  static const String serviceRequestStatusEnum = '/digx-common/sr/v1/enumerations/srStatus';

  // ── Content (icons/images referenced by id, e.g. SR infoNote.icon) ──
  static String contentById(String contentId) =>
      '/digx-common/content/v1/contents/$contentId';
  // ── Notifications (mailbox: alerts + mails) ─────────────────
  static const String mailboxCount =
      '/digx-common/collaboration/v1/mailbox/count';
  static const String mailboxAlerts =
      '/digx-common/collaboration/v1/mailbox/alerts';
  static const String mailboxMails =
      '/digx-common/collaboration/v1/mailbox/mails';
  static const String mailboxMailers =
      '/digx-common/collaboration/v1/mailbox/mailers';
  static String mailboxAlertById(String alertId) =>
      '/digx-common/collaboration/v1/mailbox/alerts/$alertId';
}
