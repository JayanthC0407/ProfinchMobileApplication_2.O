class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;
  final String phoneNumber;
  final String panNumber;
  final String profileImage;
  final String accountNumber;
  final DateTime createdAt;
  final bool isKycVerified;
  
  final String primaryAccountId;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.panNumber,
    required this.profileImage,
    required this.accountNumber,
    required this.createdAt,
    required this.isKycVerified,
    required this.primaryAccountId,
  });

  /// Builds a [UserModel] from the OBDX `GET /digx-common/user/v1/me`
  /// response, confirmed live shape:
  /// { "status": {...}, "userProfile": { "userName", "firstName",
  ///   "lastName", "partyId": {displayValue, value}, "emailId":
  ///   {displayValue, value}, "phoneNumber": {displayValue, value},
  ///   "dateOfBirth", "roles": [...] }, "dashboardResponse": {...} }
  ///
  /// `emailId.value` / `phoneNumber.value` are encrypted/opaque on the
  /// wire — NOT decryptable client-side — so we use the server-provided
  /// masked `displayValue` (e.g. "anu****profinch.com") for display
  /// everywhere instead of trying to show a real email/phone.
  factory UserModel.fromMeResponse(Map<String, dynamic> json) {
    final profile = (json['userProfile'] as Map<String, dynamic>?) ?? json;
    final partyId = profile['partyId'] as Map<String, dynamic>?;
    final emailId = profile['emailId'] as Map<String, dynamic>?;
    final phoneNumber = profile['phoneNumber'] as Map<String, dynamic>?;
    final firstName = (profile['firstName'] ?? '').toString();
    final lastName = (profile['lastName'] ?? '').toString();

    return UserModel(
      id: ((partyId != null ? partyId['value'] : null) ?? profile['userName'] ?? '').toString(),
      // username: (profile['userName'] ?? '').toString(),
      username: (firstName.isNotEmpty || lastName.isNotEmpty) ? '$firstName $lastName'.trim() : (profile['userName'] ?? '').toString(),
      email: ((emailId != null ? emailId['displayValue'] : null) ?? '').toString(),
      password: '', // never populated from the server response
      phoneNumber: ((phoneNumber != null ? phoneNumber['displayValue'] : null) ?? '').toString(),
      panNumber: '', // not present in /me response
      profileImage: '',
      accountNumber: '',
      createdAt: DateTime.now(), // not present in /me response
      isKycVerified: profile['prospect'] == false,
      primaryAccountId: '',
    )..fullName = ('$firstName $lastName').trim();
  }

  /// Convenience display name populated only via [fromMeResponse]. Not part
  /// of the primary constructor since the local dummy-data flow (sign-up)
  /// never had first/last name split out.
  String? fullName;

 UserModel copyWith({
  String? username,
  String? email,
  String? phoneNumber,
  String? primaryAccountId,
  String? profileImage,
}) 
 {
  return UserModel(
    id: id,
    username: username ?? this.username,
    email: email ?? this.email,
    password: password,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    panNumber: panNumber,
    profileImage: profileImage ?? this.profileImage,
    accountNumber: accountNumber,
    createdAt: createdAt,
    isKycVerified: isKycVerified,
    primaryAccountId:primaryAccountId ?? this.primaryAccountId,
  );
}
}