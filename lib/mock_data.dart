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

  // ================= CHAT FIX =================
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
      'tanggal': '2024-05-15',
      'isHomeCare': false,
      'status': 'Menunggu Persetujuan',
      'namaPasien': 'Sifa Harum',
      'emailPasien': 'sifa@example.com',
      'harga': 'Rp 150.000',
      'timestamp': DateTime(2024, 5, 10),
    },
    {
      'layanan': 'Imunisasi Bayi',
      'jam': '14:00',
      'tanggal': '2024-05-20',
      'isHomeCare': true,
      'status': 'Disetujui',
      'namaPasien': 'Anisa Melia',
      'emailPasien': 'anisa@example.com',
      'harga': 'Rp 200.000',
      'timestamp': DateTime(2024, 5, 12),
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
      'title': 'Pemeriksaan Dikonfirmasi',
      'message': 'Bidan telah mengkonfirmasi jadwal Anda',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
  ];
}