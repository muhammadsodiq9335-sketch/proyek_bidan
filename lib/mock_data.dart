import 'models/user_profile.dart';
export 'models/user_profile.dart';
class BidanProfile {
  final String nama;
  final String nik;
  final String nip;
  final String str;
  final String hp;
  final String alamat;

  BidanProfile({
    required this.nama,
    required this.nik,
    required this.nip,
    required this.str,
    required this.hp,
    required this.alamat,
  });
}
class JenisPelayanan {
  String nama;
  String deskripsi;
  String harga;
  String kategori;

  JenisPelayanan({
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.kategori,
  });
}

class ReviewPasien {
  final String name;
  final int rating;
  final String date;
  final String content;
  final int avatarColor;
  String? adminReply;

  ReviewPasien({
    required this.name,
    required this.rating,
    required this.date,
    required this.content,
    required this.avatarColor,
    this.adminReply,
  });
}

class ArtikelPdf {
  final String id;
  final String namaFile;
  final String urlPdf;
  final DateTime tanggalUpload;

  ArtikelPdf({
    required this.id,
    required this.namaFile,
    required this.urlPdf,
    required this.tanggalUpload,
  });
}

class MockDatabase {
  static final Map<String, String> registeredUsers = {};
  static final Map<String, UserProfile> userProfiles = {};
  static UserProfile? currentUser;

  static String rememberedEmail = '';
  static bool rememberMe = false;

  // ================= USER =================
  static void seedDummyUsers() {
    // Kosongkan agar login harus lewat Supabase
    registeredUsers.clear();
    userProfiles.clear();
  }
  
  // ================= CHAT =================
  static Map<String, List<Map<String, dynamic>>> chatRooms = {};

  //================== BIDAN =================
  static List<BidanProfile> bidanList = [];

  // ================= USER RESERVATIONS =================
  static List<Map<String, dynamic>> userReservations = [];

  // ================= JENIS PELAYANAN =================
  static List<JenisPelayanan> layananList = [];

  // ================= NOTIFICATIONS =================
  static List<Map<String, dynamic>> notifications = [];

  // ================= REVIEWS =================
  static List<ReviewPasien> reviews = [];

  // ================= ARTIKEL PDF =================
  static List<ArtikelPdf> artikelPdfList = [];
}