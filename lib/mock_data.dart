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

class MockDatabase {
  static final Map<String, String> registeredUsers = {};
  static final Map<String, UserProfile> userProfiles = {};
  static UserProfile? currentUser;

  static String rememberedEmail = '';
  static bool rememberMe = false;

  // ================= CHAT =================
  static Map<String, List<Map<String, dynamic>>> chatRooms = {
    "Sifa Harum": [
      {
        'sender': 'admin',
        'text': 'Halo Bunda Sifa 😊',
        'time': '10:00',
        'type': 'text',
      }
    ],
    "Anisa Melia": [
      {
        'sender': 'user',
        'text': 'Halo bidan',
        'time': '09:30',
        'type': 'text',
      }
    ],
  };
  //================== BIDAN =================
  static List<BidanProfile> bidanList = [
    BidanProfile(
      nama: "Siti Aminah, S.Tr.Keb",
      nik: "3512345678901234",
      nip: "1987654321",
      str: "No. STR: 123456789",
      hp: "081234567890",
      alamat: "Jl. Mawar No.10, Jember",
    ),
    BidanProfile(
      nama: "Rina Kartika, A.Md.Keb",
      nik: "3578901234567890",
      nip: "1976543210",
      str: "No. STR: 987654321",
      hp: "082345678901",
      alamat: "Jl. Melati No.5, Banyuwangi",
    ),
    BidanProfile(
      nama: "Dewi Lestari, S.Tr.Keb",
      nik: "3509876543210123",
      nip: "1990123456",
      str: "No. STR: 456789123",
      hp: "083456789012",
      alamat: "Jl. Kenanga No.7, Bondowoso",
    ),
    BidanProfile(
      nama: "Nur Aisyah, A.Md.Keb",
      nik: "3523456789012345",
      nip: "2001123456",
      str: "No. STR: 321654987",
      hp: "085678901234",
      alamat: "Jl. Anggrek No.3, Situbondo",
    ),
  ];
  // ================= USER RESERVATIONS =================
  static final List<Map<String, dynamic>> userReservations = [
    /// ================= KEMARIN =================
    {
      'layanan': 'Pemeriksaan Kehamilan',
      'jam': '09:00',
      'tanggal': '2026-05-01',

      'status': 'Dikonfirmasi',
      'statusPelayanan': 'Selesai & Pulang',

      'namaPasien': 'Sifa Harum',
      'emailPasien': 'sifa@example.com',
      'harga': 'Rp 150.000',

      'bidan': 'Siti Aminah, S.Tr.Keb',

      'timestamp': DateTime(2026, 4, 30),
    },

    /// ================= HARI INI =================

    // 🔸 MENUNGGU KONFIRMASI
    {
      'layanan': 'USG Kehamilan',
      'jam': '09:00',
      'tanggal': '2026-05-02',

      'status': 'Menunggu Persetujuan',
      'statusPelayanan': 'Menunggu',

      'namaPasien': 'Anisa Melia',
      'emailPasien': 'anisa@example.com',
      'harga': 'Rp 200.000',
      'bidan': null,
      'timestamp': DateTime(2026, 5, 1),
    },

    // 🔸 SUDAH DIKONFIRMASI (BELUM DATANG)
    {
      'layanan': 'Imunisasi Bayi',
      'jam': '10:00',
      'tanggal': '2026-05-02',

      'status': 'Dikonfirmasi',
      'statusPelayanan': 'Menunggu',

      'namaPasien': 'Rani Putri',
      'emailPasien': 'rani@example.com',
      'harga': 'Rp 200.000',
      'bidan': null,
      'timestamp': DateTime(2026, 5, 1),
    },

    // 🔸 SEDANG DILAYANI
    {
      'layanan': 'Kunjungan Bidan',
      'jam': '11:00',
      'tanggal': '2026-05-02',

      'status': 'Dikonfirmasi',
      'statusPelayanan': 'Diproses',

      'namaPasien': 'Dewi Lestari',
      'emailPasien': 'dewi@example.com',
      'harga': 'Rp 250.000',
      'bidan': 'Dewi Lestari, S.Tr.Keb',
      'timestamp': DateTime(2026, 5, 1),
    },

    // 🔸 SUDAH SELESAI & PULANG
    {
      'layanan': 'USG Kehamilan',
      'jam': '08:00',
      'tanggal': '2026-05-02',

      'status': 'Dikonfirmasi',
      'statusPelayanan': 'Selesai & Pulang',

      'namaPasien': 'Putri Ayu',
      'emailPasien': 'putri@example.com',
      'harga': 'Rp 150.000',
      'bidan': 'Siti Aminah, S.Tr.Keb',
      'timestamp': DateTime(2026, 5, 1),
    },

    /// ================= BESOK =================
    {
      'layanan': 'Pemeriksaan Kehamilan',
      'jam': '09:00',
      'tanggal': '2026-05-03',

      'status': 'Menunggu Persetujuan',
      'statusPelayanan': 'Menunggu',

      'namaPasien': 'Lina Sari',
      'emailPasien': 'lina@example.com',
      'harga': 'Rp 150.000',
      'timestamp': DateTime(2026, 5, 2),
    },
  ];
  // ================= JENIS PELAYANAN =================
  static List<JenisPelayanan> layananList = [
    // 🔥 KLINIK
    JenisPelayanan(
      nama: "USG Kehamilan",
      deskripsi: "Pemeriksaan kandungan menggunakan USG",
      harga: "Rp 150.000",
      kategori: "Klinik",
    ),
    JenisPelayanan(
      nama: "Pemeriksaan Kehamilan",
      deskripsi: "Pemeriksaan rutin ibu hamil",
      harga: "Rp 100.000",
      kategori: "Klinik",
    ),

    // 🔥 HOME CARE
    JenisPelayanan(
      nama: "Imunisasi Bayi",
      deskripsi: "Layanan imunisasi ke rumah",
      harga: "Rp 200.000",
      kategori: "Home Care",
    ),
    JenisPelayanan(
      nama: "Kunjungan Bidan",
      deskripsi: "Pemeriksaan langsung ke rumah pasien",
      harga: "Rp 250.000",
      kategori: "Home Care",
    ),
  ];
  // ================= NOTIFICATIONS =================
  static List<Map<String, dynamic>> notifications = [
    {
      'title': 'Reservasi Terkirim',
      'message': 'Reservasi Anda sedang diproses',
      'timestamp': DateTime.now(),
      'time': 'Baru saja',
      'icon': 0xe356, // Icons.info_outline.codePoint
    },
    {
      'title': 'Reservasi Dikonfirmasi',
      'message': 'Jadwal Anda telah disetujui',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'time': '2 jam yang lalu',
      'icon': 0xe156, // Icons.check_circle_outline.codePoint
    },
  ];

  // ================= REVIEWS =================
  static List<ReviewPasien> reviews = [
    ReviewPasien(
      name: 'SYIFA HADJU',
      rating: 5,
      date: '12 Jan 2026',
      content:
          'Bidan X sangat ramah dan penjelasannya sangat menenangkan. Fasilitasnya sangat bersih, membuat pengalaman USG pertama saya jadi sangat berkesan.',
      avatarColor: 0xFFE8D5E0,
    ),
  ];
}