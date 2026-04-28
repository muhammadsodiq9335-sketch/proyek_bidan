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
  // Simpan data user dengan format {email/nohp: password}
  static final Map<String, String> registeredUsers = {};

  // Simpan profil user dengan format {email/nohp: UserProfile}
  static final Map<String, UserProfile> userProfiles = {};

  // User yang sedang login
  static UserProfile? currentUser;

  // Fitur "Ingat Saya" — menyimpan email yang terakhir login
  static String rememberedEmail = '';
  static bool rememberMe = false;

  // Riwayat Reservasi (Setiap entry: {layanan, jam, tanggal, isHomeCare, status, namaPasien, emailPasien, harga})
  static final List<Map<String, dynamic>> userReservations = [
    {
      'layanan': 'Imunisasi Bayi',
      'jam': '08:00',
      'tanggal': '24 April 2026',
      'isHomeCare': false,
      'status': 'Menunggu Persetujuan',
      'namaPasien': 'Dewi Lestari',
      'emailPasien': 'dewi@example.com',
      'harga': 'Rp 150.000',
    },
    {
      'layanan': 'Pijat Bayi',
      'jam': '10:00',
      'tanggal': '24 April 2026',
      'isHomeCare': true,
      'status': 'Dikonfirmasi',
      'namaPasien': 'Maya Putri',
      'emailPasien': 'maya@example.com',
      'harga': 'Rp 200.000',
    },
  ];

  // Notifikasi (Setiap entry: {title, message, time, icon})
  static final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Pendaftaran Berhasil',
      'message': 'Selamat datang di aplikasi MORA! Akun Anda telah berhasil dibuat.',
      'time': 'Baru saja',
      'icon': 0xe156, // Icons.check_circle
    },
  ];

  // Pesan Chat (Setiap entry: {sender, text, time})
  // sender: 'admin' atau 'user'
  static final List<Map<String, dynamic>> chatMessages = [
    {
      'sender': 'admin',
      'text': 'Halo Bunda, ada yang bisa kami bantu?',
      'time': '10:00'
    }
  ];
}
