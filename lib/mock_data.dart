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

  // Riwayat Reservasi (Setiap entry: {layanan, bidan, tanggal, jam, isHomeCare, status})
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
}
