class RekamMedis {
  final String? id;
  final String? reservasiId;
  final String? userId;
  final String? bidanId;
  final DateTime? hpht;
  final DateTime? hpl;
  final String? usiaKehamilan;
  final double? beratBadan;
  final String? tensi;
  final double? tfu;
  final double? djj;
  final String? posisiJanin;
  final String? keluhan;
  final String? diagnosa;
  final String? tindakan;
  final DateTime? createdAt;

  RekamMedis({
    this.id,
    this.reservasiId,
    this.userId,
    this.bidanId,
    this.hpht,
    this.hpl,
    this.usiaKehamilan,
    this.beratBadan,
    this.tensi,
    this.tfu,
    this.djj,
    this.posisiJanin,
    this.keluhan,
    this.diagnosa,
    this.tindakan,
    this.createdAt,
  });

  factory RekamMedis.fromJson(Map<String, dynamic> json) {
    return RekamMedis(
      id: json['id'],
      reservasiId: json['reservasi_id'],
      userId: json['user_id'],
      bidanId: json['bidan_id'],
      hpht: json['hpht'] != null ? DateTime.parse(json['hpht']) : null,
      hpl: json['hpl'] != null ? DateTime.parse(json['hpl']) : null,
      usiaKehamilan: json['usia_kehamilan'],
      beratBadan: json['berat_badan']?.toDouble(),
      tensi: json['tensi'],
      tfu: json['tfu']?.toDouble(),
      djj: json['djj']?.toDouble(),
      posisiJanin: json['posisi_janin'],
      keluhan: json['keluhan'],
      diagnosa: json['diagnosa'],
      tindakan: json['tindakan'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'reservasi_id': reservasiId,
      'user_id': userId,
      'bidan_id': bidanId,
      'hpht': hpht?.toIso8601String().split('T')[0],
      'hpl': hpl?.toIso8601String().split('T')[0],
      'usia_kehamilan': usiaKehamilan,
      'berat_badan': beratBadan,
      'tensi': tensi,
      'tfu': tfu,
      'djj': djj,
      'posisi_janin': posisiJanin,
      'keluhan': keluhan,
      'diagnosa': diagnosa,
      'tindakan': tindakan,
    };
  }
}
