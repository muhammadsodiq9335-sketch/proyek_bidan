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
    print('AuthService: Memulai signIn untuk $email');
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('AuthService: Auth berhasil, User ID: ${res.user?.id}');

      if (res.user != null) {
        var profile = await SupabaseService().getUserProfile(res.user!.id);
        
        // Jika profil belum ada di tabel, buat dari metadata
        if (profile == null) {
          print('AuthService: Profil tidak ditemukan, mencoba membuat profil baru untuk ${res.user!.email}...');
          final meta = res.user!.userMetadata ?? {};
          final newProfileData = {
            'id': res.user!.id,
            'email': res.user!.email,
            'nama': meta['nama'] ?? 'User',
            'tgl_lahir': _sanitizeDate(meta['tgl_lahir']),
            'alamat': meta['alamat'] ?? '',
            'role': meta['role'] ?? 'pasien',
          };
          try {
            // Gunakan upsert agar tidak error duplicate key dan pastikan data terbaru masuk
            await _supabase.from('user_profiles').upsert(newProfileData);
            print('AuthService: Profil berhasil diperbarui/dibuat otomatis.');
            
            // Ambil ulang setelah upsert untuk memastikan kita punya data terbaru
            profile = UserProfile.fromJson(newProfileData);
          } catch (e) {
            print('AuthService: Gagal auto-create/upsert profile: $e');
            rethrow;
          }
        }
        
        currentUserProfile = profile;
      }
    } catch (e) {
      print('AuthService Error: $e');
      rethrow;
    }
  }

  // Sanitasi tanggal lahir untuk database PostgreSQL (DATE type)
  String? _sanitizeDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    String valStr = value.toString();
    
    // Jika format DD/MM/YYYY, konversi ke YYYY-MM-DD
    if (valStr.contains('/')) {
      try {
        final parts = valStr.split('/');
        if (parts.length == 3) {
          // parts[0]=dd, parts[1]=mm, parts[2]=yyyy
          return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
        }
      } catch (_) {}
    }
    
    // Cek apakah sudah format YYYY-MM-DD yang valid
    try {
      DateTime.parse(valStr);
      return valStr;
    } catch (_) {
      return null;
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
      data: {
        'nama': nama,
        'tgl_lahir': tglLahir,
        'alamat': alamat,
        'role': 'pasien',
      },
    );

    final user = response.user;
    if (user == null) throw Exception("User gagal dibuat");

    // Profile akan otomatis dibuat di tabel user_profiles saat login pertama kali
    // untuk menghindari error foreign key constraint (race condition)
    currentUserProfile = UserProfile(
      id: user.id,
      email: email,
      nama: nama,
      tglLahir: tglLahir,
      alamat: alamat,
      role: 'pasien',
    );
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

  // Ganti Password
  Future<void> changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      print('AuthService Error changePassword: $e');
      rethrow;
    }
  }
}
