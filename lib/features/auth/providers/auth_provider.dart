import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vita_min_control_helper/data/models/user.dart';

// Auth state
class AuthState {
  AuthState({
    this.userId,
    this.userEmail,
    this.username,
    this.token,
    this.tokenExpiration,
    this.isLoggedIn = false,
    this.isGuest = false,
  });

  final String? userId;
  final String? userEmail;
  final String? username;
  final String? token;
  final DateTime? tokenExpiration;
  final bool isLoggedIn;
  final bool isGuest;

  AuthState copyWith({
    String? userId,
    String? userEmail,
    String? username,
    String? token,
    DateTime? tokenExpiration,
    bool? isLoggedIn,
    bool? isGuest,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      username: username ?? this.username,
      token: token ?? this.token,
      tokenExpiration: tokenExpiration ?? this.tokenExpiration,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

// Auth notifier using Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final token = await _storage.read(key: 'token');
      final userId = await _storage.read(key: 'userId');
      final userEmail = await _storage.read(key: 'userEmail');
      final username = await _storage.read(key: 'username');
      final expirationString = await _storage.read(key: 'tokenExpiration');

      if (token != null && expirationString != null) {
        final expiration = DateTime.parse(expirationString);
        if (expiration.isAfter(DateTime.now())) {
          state = AuthState(
            userId: userId,
            userEmail: userEmail,
            username: username,
            token: token,
            tokenExpiration: expiration,
            isLoggedIn: true,
          );
        } else {
          // Token expired, clean up
          await logout();
        }
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  Future<void> setAuthData({
    required String userId,
    required String userEmail,
    required String username,
    required String token,
    required DateTime tokenExpiration,
  }) async {
    state = AuthState(
      userId: userId,
      userEmail: userEmail,
      username: username,
      token: token,
      tokenExpiration: tokenExpiration,
      isLoggedIn: true,
    );

    // Store in secure storage
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'userId', value: userId);
    await _storage.write(key: 'userEmail', value: userEmail);
    await _storage.write(key: 'username', value: username);
    await _storage.write(
      key: 'tokenExpiration',
      value: tokenExpiration.toIso8601String(),
    );
  }

  void setGuestMode() {
    // Create a random guest user
    state = AuthState(
      userId: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      username: 'Guest',
      isGuest: true,
    );
  }

  Future<void> logout() async {
    state = AuthState();

    // Clear storage
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'userEmail');
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'tokenExpiration');
  }

  User getCurrentUser() {
    return User(
      id: state.userId ?? '',
      email: state.userEmail,
      username: state.username,
      isGuest: state.isGuest,
    );
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
