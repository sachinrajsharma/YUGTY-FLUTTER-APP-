/// Authentication contract. The app talks only to this interface, so the
/// real YUGTY backend can replace [MockAuthService] without touching the UI.
abstract class AuthService {
  /// Sends a one-time code to [phone] (digits only, without country code).
  Future<void> sendOtp(String phone);

  /// Returns true when [code] is valid for [phone].
  Future<bool> verifyOtp(String phone, String code);

  /// Returns a display name for the signed-in Google user, or null if cancelled.
  Future<String?> signInWithGoogle();
}

/// Offline demo implementation: no network, no real SMS. Any 6-digit code passes.
class MockAuthService implements AuthService {
  @override
  Future<void> sendOtp(String phone) =>
      Future<void>.delayed(const Duration(milliseconds: 700));

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  @override
  Future<String?> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return 'Student';
  }
}
