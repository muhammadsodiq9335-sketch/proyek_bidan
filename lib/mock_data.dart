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
  static final List<Map<String, dynamic>> userReservations = [];

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
