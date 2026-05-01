class UserProfile {
  final String email;
  final String nama;
  final String tglLahir;
  final String alamat;

  UserProfile({
    required this.email,
    required this.nama,
    required this.tglLahir,
    required this.alamat,
  });
}

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
    {
      'layanan': 'Pemeriksaan Kehamilan',
      'jam': '10:00',
      'tanggal': '2026-04-24', // 🔥 disamakan dengan kalender
      'isHomeCare': false,
      'status': 'Menunggu Persetujuan', // 👈 ini yang muncul di admin
      'namaPasien': 'Sifa Harum',
      'emailPasien': 'sifa@example.com',
      'harga': 'Rp 150.000',
      'timestamp': DateTime(2026, 4, 20),
    },
    {
      'layanan': 'Imunisasi Bayi',
      'jam': '14:00',
      'tanggal': '2026-04-24',
      'isHomeCare': true,
      'status': 'Dikonfirmasi', // 🔥 sudah selesai
      'namaPasien': 'Anisa Melia',
      'emailPasien': 'anisa@example.com',
      'harga': 'Rp 200.000',
      'timestamp': DateTime(2026, 4, 21),
    },
  ];

  // ================= NOTIFICATIONS =================
  static List<Map<String, dynamic>> notifications = [
    {
      'title': 'Reservasi Terkirim',
      'message': 'Reservasi Anda sedang diproses',
      'timestamp': DateTime.now(),
    },
    {
      'title': 'Reservasi Dikonfirmasi',
      'message': 'Jadwal Anda telah disetujui',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
  ];
}