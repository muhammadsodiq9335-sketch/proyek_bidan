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