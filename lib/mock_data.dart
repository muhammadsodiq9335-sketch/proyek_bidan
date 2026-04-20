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
}
