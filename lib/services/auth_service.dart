import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cek apakah user sedang login
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Get current session
  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  // Login dengan Email & Password
  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Register dengan Email, Password, dan Data Profil
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nama,
    required String tglLahir,
    required String alamat,
  }) async {
    // 1. Sign up user ke Supabase Auth
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user != null) {
      // 2. Simpan profil user ke tabel user_profiles
      await _supabase.from('user_profiles').insert({
        'id': user.id,
        'email': email,
        'nama': nama,
        'tgl_lahir': tglLahir,
        'alamat': alamat,
      });
    }

    return response;
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Ingat Saya (Remember Me) - menggunakan SharedPreferences
  Future<void> saveRememberMe(String email, bool isRemembered) async {
    final prefs = await SharedPreferences.getInstance();
    if (isRemembered) {
      await prefs.setString('remembered_email', email);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('remembered_email');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<Map<String, dynamic>> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remembered_email') ?? '';
    final isRemembered = prefs.getBool('remember_me') ?? false;
    return {'email': email, 'isRemembered': isRemembered};
  }
}
