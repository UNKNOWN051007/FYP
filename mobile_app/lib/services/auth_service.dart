import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// True while a Supabase password-recovery deep link is being handled —
  /// suppresses the auto-redirect to /main in main.dart's auth listener so
  /// the user lands on /reset-password instead.
  static bool isRecovering = false;

  static Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    final user = res.user;
    if (user == null) throw Exception('Sign up failed');
    // Supabase silently returns empty identities when the email already exists
    if (user.identities != null && user.identities!.isEmpty) {
      throw Exception('An account with this email already exists. Please sign in instead.');
    }
    return UserModel(userId: user.id, email: email, fullName: fullName);
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    if (res.user == null) throw Exception('Sign in failed');
  }

  static Future<void> resendConfirmation(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  static Future<void> resetPassword(String email) async {
    // On web: send user back to the current origin so Supabase's recovery
    // tokens land on the running app. On native: use a custom scheme so
    // the OS routes the link back to the app (must be declared in
    // AndroidManifest/Info.plist if mobile deep-linking is needed).
    final redirectTo = kIsWeb
        ? '${Uri.base.origin}${Uri.base.path}'
        : 'io.supabase.wagewise://reset-password';
    await _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<UserModel?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    var data = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    // Profile row missing (trigger may have failed or user pre-dates the trigger).
    // Create it now from auth metadata so the app can proceed.
    if (data == null) {
      final fullName = (user.userMetadata?['full_name'] as String?)?.isNotEmpty == true
          ? user.userMetadata!['full_name'] as String
          : user.email?.split('@').first ?? 'User';
      await _client.from('user_profiles').upsert({
        'user_id': user.id,
        'full_name': fullName,
        'language_pref': 'en',
      });
      data = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
    }

    if (data == null) return null;
    return UserModel.fromMap(data, user.email ?? '');
  }

  static Future<void> updateProfile(UserModel profile) async {
    await _client.from('user_profiles').upsert(profile.toMap());
  }

  static User? get currentUser => _client.auth.currentUser;

  static bool get isSignedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
