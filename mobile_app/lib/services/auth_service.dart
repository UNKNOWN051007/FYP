import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  User? get currentUser => _supabase.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    if (response.user == null) {
      throw const AuthException('Sign-up failed. Please try again.');
    }
    return UserModel(
      userId: response.user!.id,
      email: email,
      fullName: fullName,
    );
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw const AuthException('Invalid email or password.');
    }
    final profile = await _fetchProfile(response.user!.id);
    return profile ??
        UserModel(
          userId: response.user!.id,
          email: email,
          fullName: response.user!.userMetadata?['full_name'] as String? ?? '',
        );
  }

  Future<void> signOut() => _supabase.auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _supabase.auth.resetPasswordForEmail(email);

  Future<UserModel?> _fetchProfile(String userId) async {
    try {
      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();
      return UserModel.fromJson({
        ...data as Map<String, dynamic>,
        'email': currentUser?.email ?? '',
      });
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  Future<void> updateProfile(UserModel profile) async {
    await _supabase
        .from('user_profiles')
        .upsert(profile.toJson());
  }
}
