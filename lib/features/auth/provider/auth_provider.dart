import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/navigation/navigation_service.dart';
import 'package:profinch_mobile_application/core/network/api_exception.dart';
import 'package:profinch_mobile_application/core/network/session_manager.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import 'package:profinch_mobile_application/core/services/biometric_service.dart';
import 'package:profinch_mobile_application/data/models/user_model.dart';
import 'package:profinch_mobile_application/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  AuthProvider() {
    // Registered once here so ANY API call, from any screen/provider, that
    // comes back 401/403 (expired/invalidated session) ends up redirecting
    // to the login screen — instead of the app just sitting on the current
    // screen with every subsequent call silently failing.
    SessionManager.instance.onSessionExpired = _handleSessionExpired;
  }

  void _handleSessionExpired() {
    currentUser = null;
    otpPending = false;
    isLoading = false;
    errorMessage = 'Your session has expired. Please log in again.';
    notifyListeners();

    final navigator = NavigationService.navigatorKey.currentState;
    // Clears the entire navigation stack (dashboard, transfers, whatever
    // screen the user was on) so they land cleanly on login rather than
    // being able to "back" into stale authenticated screens.
    navigator?.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);

    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please log in again.'),
        ),
      );
    }
  }

  UserModel? currentUser;
  bool isLoading = false;

  /// Set whenever [login] fails — the login screen can show this instead
  /// of a generic "Invalid username or password" message.
  String? errorMessage;

  /// Cached separately from [currentUser] so PIN/Pattern quick-login can
  /// restore the *actual* logged-in user after logout, rather than only
  /// ever finding matches in the local dummy user list.
  UserModel? _lastLoggedInUser;

  // ── PIN ──────────────────────────────────────────────────────
  String? _pin;
  String? _pinEmail; // remember which user set the PIN

  bool get isPinSet => _pin != null && _pin!.isNotEmpty;

  void setPin(String pin) {
    _pin = pin;
    _pinEmail = currentUser?.email; // store whose PIN this is
    notifyListeners();
  }

  /// Verifies the PIN and restores currentUser from repository if needed.
  bool verifyPin(String pin) {
    if (_pin == null || pin != _pin) return false;
    // Restore currentUser if it was cleared by logout
    if (currentUser == null && _pinEmail != null) {
      currentUser = (_lastLoggedInUser?.email == _pinEmail)
          ? _lastLoggedInUser
          : _repository.getUserByEmail(_pinEmail!);
      notifyListeners();
    }
    return true;
  }

  void clearPin() {
    _pin = null;
    _pinEmail = null;
    notifyListeners();
  }

  // ── Pattern ──────────────────────────────────────────────────
  List<int>? _pattern;
  String? _patternEmail;

  bool get isPatternSet => _pattern != null && _pattern!.isNotEmpty;

  void setPattern(List<int> pattern) {
    _pattern = List<int>.from(pattern);
    _patternEmail = currentUser?.email;
    notifyListeners();
  }

  bool verifyPattern(List<int> pattern) {
    if (_pattern == null || _pattern!.length != pattern.length) return false;
    for (int i = 0; i < pattern.length; i++) {
      if (_pattern![i] != pattern[i]) return false;
    }
    // Restore currentUser if cleared by logout
    if (currentUser == null && _patternEmail != null) {
      currentUser = (_lastLoggedInUser?.email == _patternEmail)
          ? _lastLoggedInUser
          : _repository.getUserByEmail(_patternEmail!);
      notifyListeners();
    }
    return true;
  }

  void clearPattern() {
    _pattern = null;
    _patternEmail = null;
    notifyListeners();
  }

  // ── Biometric ─────────────────────────────────────────────────
  bool _isBiometricEnabled = false;
  bool get isBiometricEnabled => _isBiometricEnabled;

  Future<bool> checkBiometricAvailable() async {
    return await BiometricService.instance.isAvailable();
  }

  Future<bool> authenticateWithBiometric() async {
    return await BiometricService.instance.authenticate();
  }

  void setBiometricEnabled(bool value) {
    _isBiometricEnabled = value;
    notifyListeners();
  }

  // ── Standard login ────────────────────────────────────────────
  void updateUser(UserModel updatedUser) {
    currentUser = updatedUser;
    notifyListeners();
  }

  void updateProfileImage(String imagePath) {
    if (currentUser == null) return;
    currentUser = currentUser!.copyWith(profileImage: imagePath);
    notifyListeners();
  }

  /// True once step 3 (POST /login) succeeded but step 4 (GET /me) came
  /// back requiring OTP verification — the UI should show an OTP screen
  /// and call [verifyLoginOtp] rather than treating login as complete.
  bool otpPending = false;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    otpPending = false;
    notifyListeners();

    try {
      // Steps 1-3: encrypt password, POST /login, store JWT.
      await _repository.login(username: username, password: password);

      // Step 4: GET /me — commonly OTP-gated on first call.
      try {
        final user = await _repository.fetchCurrentUser();
        currentUser = user;
        _lastLoggedInUser = user;
        isLoading = false;
        notifyListeners();
        return true;
      } on ApiException catch (e) {
        if (e.requiresChallenge) {
          // Login itself succeeded (we have a JWT) — just need OTP next.
          otpPending = true;
          isLoading = false;
          notifyListeners();
          return true;
        }
        rethrow;
      }
    } on ApiException catch (e) {
      isLoading = false;
      errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Call after [login] returns with [otpPending] true, once the user has
  /// entered the OTP sent to their registered mobile number.
  Future<bool> verifyLoginOtp(String otp) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.verifyLoginOtp(otp);
      currentUser = user;
      _lastLoggedInUser = user;
      otpPending = false;
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      isLoading = false;
      errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Verification failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Re-triggers the OTP send for a fresh code.
  Future<void> resendLoginOtp() async {
    try {
      await _repository.resendLoginOtp();
    } catch (_) {
      // Non-fatal — the OTP screen's existing referenceNo is still valid
      // until the user tries to verify again.
    }
  }

  bool emailExists(String email) => _repository.emailExists(email);

  bool usernameExists(String username) => _repository.usernameExists(username);

  bool passwordMatches({required String email, required String password}) =>
      _repository.passwordMatches(email: email, password: password);

  void logout() {
    currentUser = null;
    // PIN/Pattern/Biometric intentionally kept after logout
    // so user can still quick-login on next session
    notifyListeners();

    // Fire-and-forget: invalidate the session server-side too. Errors here
    // are non-fatal since we've already cleared local state.
    _repository.logout().catchError((_) {});
  }

  //update profile image
  Uint8List? profileImageBytes;

  void updateProfileImageBytes(Uint8List bytes) {
    profileImageBytes = bytes;
    notifyListeners();
  }

  //
  String? get pinUsername {
    if (_pinEmail == null) return null;
    return _repository.getUserByEmail(_pinEmail!)?.username;
  }

  String? get patternUsername {
    if (_patternEmail == null) return null;
    return _repository.getUserByEmail(_patternEmail!)?.username;
  }
}
