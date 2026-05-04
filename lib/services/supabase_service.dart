import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../mock_data.dart'; // Tetap diimpor sementara untuk model ArtikelPdf jika belum dipindah

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

  Future<void> updateUserProfile(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('user_profiles').update(data).eq('id', id);
    } catch (e) {
      print('Error updateUserProfile: $e');
      rethrow;
    }
  }

  // ================= RESERVASI =================
  Future<List<Map<String, dynamic>>> getReservasi({String? userId}) async {
    try {
      var query = _supabase.from('reservasi').select('''
        *,
        bidan_profiles (nama)
      ''');
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      final data = await query.order('created_at', ascending: false);
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

  Future<void> updateStatusReservasi(String id, String status, {String? statusPelayanan, String? bidanId}) async {
    try {
      final Map<String, dynamic> updates = {'status': status};
      if (statusPelayanan != null) updates['status_pelayanan'] = statusPelayanan;
      if (bidanId != null) updates['bidan_id'] = bidanId;
      
      await _supabase.from('reservasi').update(updates).eq('id', id);
    } catch (e) {
      print('Error updateStatusReservasi: $e');
      rethrow;
    }
  }

  Future<void> updateReservasi(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('reservasi').update(data).eq('id', id);
    } catch (e) {
      print('Error updateReservasi: $e');
      rethrow;
    }
  }

  // ================= BIDAN =================
  Future<List<Map<String, dynamic>>> getBidan() async {
    try {
      final data = await _supabase.from('bidan_profiles').select().order('nama');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getBidan: $e');
      return [];
    }
  }

  // ================= JENIS PELAYANAN (TABLE: layanan) =================
  Future<List<Map<String, dynamic>>> getJenisPelayanan() async {
    try {
      final data = await _supabase.from('layanan').select().order('nama');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getJenisPelayanan: $e');
      return [];
    }
  }

  // ================= USERS (ADMIN) =================
  Future<List<Map<String, dynamic>>> getAllUserProfiles({String? role}) async {
    try {
      var query = _supabase.from('user_profiles').select();
      if (role != null) {
        query = query.eq('role', role);
      }
      final data = await query.order('nama');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getAllUserProfiles: $e');
      return [];
    }
  }

  // ================= NOTIFIKASI =================
  Future<List<Map<String, dynamic>>> getNotifikasi(String userId) async {
    try {
      final data = await _supabase
          .from('notifikasi')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getNotifikasi: $e');
      return [];
    }
  }

  // ================= BIDAN (ADMIN) =================
  Future<void> tambahBidan(Map<String, dynamic> data) async {
    try {
      await _supabase.from('bidan_profiles').insert(data);
    } catch (e) {
      print('Error tambahBidan: $e');
      rethrow;
    }
  }

  Future<void> updateBidan(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('bidan_profiles').update(data).eq('id', id);
    } catch (e) {
      print('Error updateBidan: $e');
      rethrow;
    }
  }

  Future<void> deleteBidan(String id) async {
    try {
      await _supabase.from('bidan_profiles').delete().eq('id', id);
    } catch (e) {
      print('Error deleteBidan: $e');
      rethrow;
    }
  }

  // ================= JENIS PELAYANAN (ADMIN) (TABLE: layanan) =================
  Future<void> tambahJenisPelayanan(Map<String, dynamic> data) async {
    try {
      await _supabase.from('layanan').insert(data);
    } catch (e) {
      print('Error tambahJenisPelayanan: $e');
      rethrow;
    }
  }

  Future<void> updateJenisPelayanan(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('layanan').update(data).eq('id', id);
    } catch (e) {
      print('Error updateJenisPelayanan: $e');
      rethrow;
    }
  }

  Future<void> deleteJenisPelayanan(String id) async {
    try {
      await _supabase.from('layanan').delete().eq('id', id);
    } catch (e) {
      print('Error deleteJenisPelayanan: $e');
      rethrow;
    }
  }

  // ================= ADMIN HELPERS =================
  Future<String?> getFirstAdminId() async {
    try {
      final data = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('role', 'admin')
          .limit(1)
          .maybeSingle();
      return data?['id']?.toString();
    } catch (e) {
      print('Error getFirstAdminId: $e');
      return null;
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

  Future<void> balasReview(String reviewId, String reply) async {
    try {
      await _supabase.from('reviews').update({'admin_reply': reply}).eq('id', reviewId);
    } catch (e) {
      print('Error balasReview: $e');
      rethrow;
    }
  }

  Future<void> hapusBalasanReview(String reviewId) async {
    try {
      await _supabase.from('reviews').update({'admin_reply': null}).eq('id', reviewId);
    } catch (e) {
      print('Error hapusBalasanReview: $e');
      rethrow;
    }
  }

  // ================= CHAT =================
  Stream<List<Map<String, dynamic>>> getChatMessages(String userId, String otherId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.where((m) => 
          (m['sender_id'] == userId && m['receiver_id'] == otherId) ||
          (m['sender_id'] == otherId && m['receiver_id'] == userId)
        ).toList());
  }

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    try {
      await _supabase.from('chat_messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'text': text,
      });
    } catch (e) {
      print('Error sendMessage: $e');
      rethrow;
    }
  }

  // ================= ARTIKEL PDF =================
  Future<List<ArtikelPdf>> getArtikelPdf() async {
    try {
      final data = await _supabase.from('artikel_pdf').select().order('tanggal_upload', ascending: false);
      return (data as List).map((e) {
        final rawDate = e['tanggal_upload']?.toString() ?? '';
        DateTime parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
        
        return ArtikelPdf(
          id: e['id']?.toString() ?? '',
          namaFile: e['nama_file'] ?? 'Tanpa Nama',
          urlPdf: e['url_pdf'] ?? '',
          tanggalUpload: parsedDate,
        );
      }).toList();
    } catch (e) {
      print('Error getArtikelPdf: $e');
      return [];
    }
  }

  Future<void> tambahArtikelPdf(Map<String, dynamic> data) async {
    try {
      await _supabase.from('artikel_pdf').insert(data);
    } catch (e) {
      print('Error tambahArtikelPdf: $e');
      rethrow;
    }
  }

  Future<void> deleteArtikelPdf(String id) async {
    try {
      await _supabase.from('artikel_pdf').delete().eq('id', id);
    } catch (e) {
      print('Error deleteArtikelPdf: $e');
      rethrow;
    }
  }
}
