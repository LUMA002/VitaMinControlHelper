import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth state
class AuthState {
  AuthState({
    this.isLoggedIn = false,
    this.isGuestMode = false,
    this.userId,
    this.userEmail,
    this.username,
  });

  final bool isLoggedIn;
  final bool isGuestMode;
  final String? userId;
  final String? userEmail;
  final String? username;

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isGuestMode,
    String? userId,
    String? userEmail,
    String? username,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuestMode: isGuestMode ?? this.isGuestMode,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      username: username ?? this.username,
    );
  }
}

// Auth notifier using Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(); // Initial state
  }

  void setLoggedIn(bool isLoggedIn) {
    state = state.copyWith(isLoggedIn: isLoggedIn);
  }

  void setGuestMode(bool isGuestMode) {
    state = state.copyWith(isGuestMode: isGuestMode);
  }

  void setUserData({
    required String userId,
    required String userEmail,
    required String username,
  }) {
    state = state.copyWith(
      userId: userId,
      userEmail: userEmail,
      username: username,
    );
  }

  void logout() {
    state = AuthState();
  }
}

// Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
