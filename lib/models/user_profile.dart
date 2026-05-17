class UserProfile {
  final String id;
  final String email;
  final String nama;
  final String tglLahir;
  final String alamat;
  final String role; // 'pasien' atau 'admin'
  final String? fotoUrl;

  UserProfile({
    required this.id,
    required this.email,
    required this.nama,
    this.tglLahir = '',
    this.alamat = '',
    this.role = 'pasien',
    this.fotoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      tglLahir: json['tgl_lahir']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      role: json['role']?.toString() ?? 'pasien',
      fotoUrl: json['foto_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'tgl_lahir': tglLahir,
      'alamat': alamat,
      'role': role,
      'foto_url': fotoUrl,
    };
  }
}
