// Fallback authentication service for testing without Firebase
class LocalAuthService {
  static const String _demoEmail = 'punit.mece@gmail.com';
  
  static bool _isLoggedIn = false;
  static String? _currentUserEmail;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUserEmail => _currentUserEmail;

  static Future<bool> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Local auth is only for fallback - should use Firebase auth in production
    if (email.trim().toLowerCase() == _demoEmail) {
      _isLoggedIn = true;
      _currentUserEmail = email;
      return true;
    }

    throw Exception('Invalid credentials. Please use Firebase authentication.');
  }

  static Future<void> signOut() async {
    _isLoggedIn = false;
    _currentUserEmail = null;
  }

  static bool isValidAdmin(String email) {
    return email.trim().toLowerCase() == _demoEmail;
  }
}
