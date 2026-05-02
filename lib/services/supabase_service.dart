import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ================= USERS =================
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e) {
      print('Error getUserProfile: $e');
      return null;
    }
  }

  // ================= RESERVASI =================
  Future<List<Map<String, dynamic>>> getReservasi({String? emailPasien}) async {
    try {
      var query = _supabase.from('reservasi').select().order('created_at', ascending: false);
      if (emailPasien != null) {
        query = query.eq('email_pasien', emailPasien);
      }
      final data = await query;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getReservasi: $e');
      return [];
    }
  }

  Future<void> tambahReservasi(Map<String, dynamic> reservasiData) async {
    try {
      await _supabase.from('reservasi').insert(reservasiData);
    } catch (e) {
      print('Error tambahReservasi: $e');
      rethrow;
    }
  }

  Future<void> updateStatusReservasi(String id, String status, {String? statusPelayanan, String? bidan}) async {
    try {
      final Map<String, dynamic> updates = {'status': status};
      if (statusPelayanan != null) updates['status_pelayanan'] = statusPelayanan;
      if (bidan != null) updates['bidan'] = bidan;
      
      await _supabase.from('reservasi').update(updates).eq('id', id);
    } catch (e) {
      print('Error updateStatusReservasi: $e');
      rethrow;
    }
  }

  // ================= BIDAN =================
  Future<List<Map<String, dynamic>>> getBidan() async {
    try {
      final data = await _supabase.from('bidan').select().order('nama');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getBidan: $e');
      return [];
    }
  }

  // ================= JENIS PELAYANAN =================
  Future<List<Map<String, dynamic>>> getJenisPelayanan() async {
    try {
      final data = await _supabase.from('jenis_pelayanan').select().order('nama');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getJenisPelayanan: $e');
      return [];
    }
  }

  // ================= NOTIFIKASI =================
  Future<List<Map<String, dynamic>>> getNotifikasi(String email) async {
    try {
      final data = await _supabase
          .from('notifikasi')
          .select()
          .eq('user_email', email)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getNotifikasi: $e');
      return [];
    }
  }

  Future<void> tambahNotifikasi(String email, String title, String message) async {
    try {
      await _supabase.from('notifikasi').insert({
        'user_email': email,
        'title': title,
        'message': message,
      });
    } catch (e) {
      print('Error tambahNotifikasi: $e');
    }
  }

  // ================= REVIEWS =================
  Future<List<Map<String, dynamic>>> getReviews() async {
    try {
      final data = await _supabase.from('reviews').select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getReviews: $e');
      return [];
    }
  }

  Future<void> tambahReview(Map<String, dynamic> reviewData) async {
    try {
      await _supabase.from('reviews').insert(reviewData);
    } catch (e) {
      print('Error tambahReview: $e');
      rethrow;
    }
  }

  Future<void> balasReview(String id, String adminReply) async {
    try {
      await _supabase.from('reviews').update({'admin_reply': adminReply}).eq('id', id);
    } catch (e) {
      print('Error balasReview: $e');
      rethrow;
    }
  }
}
