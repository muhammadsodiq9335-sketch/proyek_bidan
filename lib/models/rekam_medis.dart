class RekamMedis {
  final String? id;
  final String? reservasiId;
  final String? userId;
  final String? bidanId;
  final String? subjective;
  final String? objective;
  final String? assessment;
  final String? plan;
  final DateTime? createdAt;

  RekamMedis({
    this.id,
    this.reservasiId,
    this.userId,
    this.bidanId,
    this.subjective,
    this.objective,
    this.assessment,
    this.plan,
    this.createdAt,
  });

  factory RekamMedis.fromJson(Map<String, dynamic> json) {
    return RekamMedis(
      id: json['id'],
      reservasiId: json['reservasi_id'],
      userId: json['user_id'],
      bidanId: json['bidan_id'],
      subjective: json['subjective'],
      objective: json['objective'],
      assessment: json['assessment'],
      plan: json['plan'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'reservasi_id': reservasiId,
      'user_id': userId,
      'bidan_id': bidanId,
      'subjective': subjective,
      'objective': objective,
      'assessment': assessment,
      'plan': plan,
    };
  }
}
