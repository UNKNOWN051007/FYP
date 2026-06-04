import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _client.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user == null) throw Exception('Sign up failed');
    await _client.from('user_profiles').upsert({
      'user_id': user.id,
      'full_name': fullName,
      'language_pref': 'en',
    });
    return UserModel(userId: user.id, email: email, fullName: fullName);
  }

  static Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    final user = res.user;
    if (user == null) throw Exception('Sign in failed');
    return await getProfile() ?? UserModel(userId: user.id, email: email, fullName: '');
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<UserModel?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
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
