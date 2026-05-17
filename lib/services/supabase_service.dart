import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/artikel_pdf.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ================= USERS =================
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      print('SupabaseService: Mengambil profil untuk ID: $userId');
      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (data == null) {
        print('SupabaseService: Data profil tidak ditemukan di tabel user_profiles');
        return null;
      }
      
      print('SupabaseService: Data ditemukan: $data');
      return UserProfile.fromJson(data);
    } catch (e) {
      print('SupabaseService Error getUserProfile: $e');
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

  /// Helper: flatten nested joined data ke top-level map
  Map<String, dynamic> _flattenReservasi(Map raw) {
    final map = Map<String, dynamic>.from(raw);
    // Flatten bidan_profiles
    final bidan = map['bidan_profiles'];
    if (bidan is Map) {
      map['nama_bidan'] ??= bidan['nama'];
    }
    // Flatten user_profiles (tgl_lahir, alamat, foto_url)
    final up = map['user_profiles'];
    if (up is Map) {
      map['tgl_lahir'] ??= up['tgl_lahir'];
      map['alamat'] ??= up['alamat'];
      map['nama_user'] ??= up['nama'];
      map['foto_url'] ??= up['foto_url'];
    }
    // Flatten layanan
    final layan = map['layanan_data'];
    if (layan is Map) {
      map['nama_layanan'] ??= layan['nama'];
      map['harga_layanan'] ??= layan['harga'];
      map['kategori_layanan'] ??= layan['kategori'];
      map['deskripsi_layanan'] ??= layan['deskripsi'];
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getReservasi({String? userId}) async {
    try {
      var query = _supabase.from('reservasi').select('''
        *,
        bidan_profiles (nama),
        user_profiles (tgl_lahir, alamat, nama, foto_url),
        layanan_data:layanan_id ( nama, harga, kategori, deskripsi )
      ''');
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      final data = await query.order('created_at', ascending: false);
      return (data as List).map((r) => _flattenReservasi(r as Map)).toList();
    } catch (e) {
      print('Error getReservasi: $e');
      return [];
    }
  }

  /// Filter reservasi berdasarkan tanggal tertentu (field 'tanggal' di tabel reservasi)
  Future<List<Map<String, dynamic>>> getReservasiByDate(DateTime date) async {
    try {
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = await _supabase
          .from('reservasi')
          .select('''
            *,
            bidan_profiles (nama),
            user_profiles (tgl_lahir, alamat, nama, foto_url),
            layanan_data:layanan_id ( nama, harga, kategori, deskripsi )
          ''')
          .eq('tanggal', dateStr)
          .order('created_at', ascending: false);
      return (data as List).map((r) => _flattenReservasi(r as Map)).toList();
    } catch (e) {
      print('Error getReservasiByDate: $e');
      return [];
    }
  }

  /// Filter reservasi berdasarkan rentang tanggal (field 'tanggal' di tabel reservasi)
  Future<List<Map<String, dynamic>>> getReservasiByDateRange(DateTime start, DateTime end) async {
    try {
      final startStr =
          '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
      final endStr =
          '${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
      final data = await _supabase
          .from('reservasi')
          .select('''
            *,
            bidan_profiles (nama),
            user_profiles (tgl_lahir, alamat, nama, foto_url),
            layanan_data:layanan_id ( nama, harga, kategori, deskripsi )
          ''')
          .gte('tanggal', startStr)
          .lte('tanggal', endStr)
          .order('created_at', ascending: false);
      return (data as List).map((r) => _flattenReservasi(r as Map)).toList();
    } catch (e) {
      print('Error getReservasiByDateRange: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> tambahReservasi(Map<String, dynamic> reservasiData) async {
    try {
      final response = await _supabase.from('reservasi').insert(reservasiData).select().single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error tambahReservasi: $e');
      rethrow;
    }
  }

  Future<void> updateStatusReservasi(String id, String status, {String? statusPelayanan, String? bidanId, String? alasanDitolak}) async {
    try {
      final Map<String, dynamic> updates = {'status': status};
      if (statusPelayanan != null) updates['status_pelayanan'] = statusPelayanan;
      if (bidanId != null) updates['bidan_id'] = bidanId;
      if (alasanDitolak != null) updates['alasan_ditolak'] = alasanDitolak;
      
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

  Future<void> tambahNotifikasi({
    required String userId,
    required String title,
    required String message,
    String icon = 'info',
    String? screen,
  }) async {
    try {
      await _supabase.from('notifikasi').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'icon': icon,
        'screen': screen,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tambahNotifikasi: $e');
    }
  }

  Future<void> markNotifikasiSebagaiDibaca(String userId) async {
    try {
      await _supabase
          .from('notifikasi')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('Error markNotifikasiSebagaiDibaca: $e');
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
      // Mencari user dengan role 'admin' atau 'Admin'
      final data = await _supabase
          .from('user_profiles')
          .select('id')
          .or('role.eq.admin,role.eq.Admin')
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

  Future<void> updateChatMessage(String messageId, String text) async {
    try {
      await _supabase.from('chat_messages').update({'text': text}).eq('id', messageId);
    } catch (e) {
      print('Error updateChatMessage: $e');
      rethrow;
    }
  }

  Future<void> deleteChatMessage(String messageId) async {
    try {
      await _supabase.from('chat_messages').delete().eq('id', messageId);
    } catch (e) {
      print('Error deleteChatMessage: $e');
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

  // ================= REKAM MEDIS =================
  Future<Map<String, dynamic>?> getRekamMedisByReservasi(String reservasiId) async {
    try {
      final data = await _supabase
          .from('rekam_medis')
          .select()
          .eq('reservasi_id', reservasiId)
          .maybeSingle();
      return data;
    } catch (e) {
      print('Error getRekamMedisByReservasi: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRekamMedisByUser(String userId) async {
    try {
      final data = await _supabase
          .from('rekam_medis')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getRekamMedisByUser: $e');
      return [];
    }
  }

  // ================= STORAGE / AVATAR =================

  /// Upload foto profil ke bucket 'avatars'
  Future<String?> uploadAvatar({
    required String userId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final path = 'avatars/$userId/$fileName';
      
      // Upload ke storage
      await _supabase.storage.from('avatars').uploadBinary(
        path,
        fileBytes as dynamic, // Support web/mobile bytes
        fileOptions: const FileOptions(upsert: true),
      );

      // Ambil Public URL
      final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('DEBUG: Error uploadAvatar failed: $e');
      return null;
    }
  }

  /// Upload foto chat ke bucket 'chat_images'
  Future<String?> uploadChatImage({
    required String senderId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final path = 'chats/$senderId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      // Upload ke storage
      await _supabase.storage.from('chat_images').uploadBinary(
        path,
        fileBytes as dynamic,
        fileOptions: const FileOptions(upsert: true),
      );

      // Ambil Public URL
      return _supabase.storage.from('chat_images').getPublicUrl(path);
    } catch (e) {
      print('DEBUG: Error uploadChatImage failed: $e');
      print('DEBUG: Make sure bucket "chat_images" exists and is PUBLIC');
      return null;
    }
  }

  /// Update URL foto di tabel user_profiles atau bidan_profiles
  Future<bool> updateProfileFoto(String id, String fotoUrl, {bool isBidan = false}) async {
    try {
      final table = isBidan ? 'bidan_profiles' : 'user_profiles';
      await _supabase.from(table).update({'foto_url': fotoUrl}).eq('id', id);
      return true;
    } catch (e) {
      print('Error updateProfileFoto: $e');
      return false;
    }
  }

  Future<void> tambahRekamMedis(Map<String, dynamic> data) async {
    try {
      // Cek dulu apakah sudah ada rekam medis untuk reservasi ini
      final existing = await _supabase
          .from('rekam_medis')
          .select('id')
          .eq('reservasi_id', data['reservasi_id'])
          .maybeSingle();

      if (existing != null) {
        // Jika ada, tambahkan ID-nya ke data agar Supabase melakukan UPDATE
        data['id'] = existing['id'];
      }

      await _supabase.from('rekam_medis').upsert(data);
    } catch (e) {
      print('Error tambahRekamMedis: $e');
      rethrow;
    }
  }

  // ── NEW METHODS (NOT DUPLICATED) ──
  Future<Map<String, dynamic>?> getReviewByReservation(String resId) async {
    final res = await _supabase.from('reviews').select().eq('reservasi_id', resId).maybeSingle();
    return res;
  }

  Future<void> updateAdminReply(String reviewId, String reply) async {
    await _supabase.from('reviews').update({'admin_reply': reply}).eq('id', reviewId);
  }

  // ── REPORTING METHODS ──
  Future<List<Map<String, dynamic>>> getReportData() async {
    try {
      final res = await _supabase
          .from('reservasi')
          .select()
          .eq('status', 'Selesai')
          .order('tanggal', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print('Error getReportData: $e');
      return [];
    }
  }

  // ================= PAYMENT SETTINGS =================
  Future<Map<String, dynamic>> getPaymentSettings() async {
    try {
      final data = await _supabase
          .from('payment_settings')
          .select()
          .eq('id', 1)
          .maybeSingle();
      
      if (data == null) {
        return {
          'bank_name': 'BCA Syariah',
          'rek_number': '0631999999',
          'rek_name': 'A.n ANNISA',
          'qris_nmid': 'ID1026496531744',
          'qris_name': 'TAMAN IBU BIDAN ANNISA - HOME SERVICE',
          'qris_code': 'A01',
          'qris_url': '',
        };
      }
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Error getPaymentSettings: $e');
      return {
        'bank_name': 'BCA Syariah',
        'rek_number': '0631999999',
        'rek_name': 'A.n ANNISA',
        'qris_nmid': 'ID1026496531744',
        'qris_name': 'TAMAN IBU BIDAN ANNISA - HOME SERVICE',
        'qris_code': 'A01',
        'qris_url': '',
      };
    }
  }

  Future<void> updatePaymentSettings(Map<String, dynamic> data) async {
    try {
      final updateData = Map<String, dynamic>.from(data);
      updateData['id'] = 1;
      updateData['updated_at'] = DateTime.now().toIso8601String();
      await _supabase.from('payment_settings').upsert(updateData);
    } catch (e) {
      print('Error updatePaymentSettings: $e');
      rethrow;
    }
  }

  Future<String?> uploadQrisImage({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final path = 'qris/$fileName';
      
      await _supabase.storage.from('avatars').uploadBinary(
        path,
        fileBytes as dynamic,
        fileOptions: const FileOptions(upsert: true),
      );

      final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error uploadQrisImage: $e');
      return null;
    }
  }
}
