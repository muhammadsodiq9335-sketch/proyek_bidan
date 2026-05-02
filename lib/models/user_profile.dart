class UserProfile {
  final String id;
  final String email;
  final String nama;
  final String tglLahir;
  final String alamat;

  UserProfile({
    required this.id,
    required this.email,
    required this.nama,
    required this.tglLahir,
    required this.alamat,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      nama: json['nama'] as String,
      tglLahir: json['tgl_lahir'] as String,
      alamat: json['alamat'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'tgl_lahir': tglLahir,
      'alamat': alamat,
    };
  }
}
