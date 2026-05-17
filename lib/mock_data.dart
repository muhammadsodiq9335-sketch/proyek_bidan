import 'models/user_profile.dart';
import 'models/bidan_profile.dart';
import 'models/jenis_pelayanan.dart';
import 'models/review_pasien.dart';
import 'models/artikel_pdf.dart';

export 'models/user_profile.dart';
export 'models/bidan_profile.dart';
export 'models/jenis_pelayanan.dart';
export 'models/review_pasien.dart';
export 'models/artikel_pdf.dart';

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