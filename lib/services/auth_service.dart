import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static UserProfile? currentUserProfile;

  // Cek apakah user sedang login
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Login dengan Email & Password
  Future<void> signIn({required String email, required String password}) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user != null) {
      final profile = await SupabaseService().getUserProfile(res.user!.id);
      currentUserProfile = profile;
    }
  }

  // Register dengan Email, Password, dan Data Profil
  Future<void> signUp({
    required String email,
    required String password,
    required String nama,
    required String tglLahir,
    required String alamat,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception("User gagal dibuat");

    final profileData = {
      'id': user.id,
      'email': email,
      'nama': nama,
      'tgl_lahir': tglLahir,
      'alamat': alamat,
      'role': 'pasien', // Default role untuk pendaftaran baru
    };

    await _supabase.from('user_profiles').insert(profileData);
    
    currentUserProfile = UserProfile.fromJson(profileData);
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    currentUserProfile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remembered_email');
    await prefs.remove('remember_me');
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
