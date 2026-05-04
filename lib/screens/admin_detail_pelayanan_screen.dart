import 'package:flutter/material.dart';
import 'admin_detail_pembayaran_screen.dart';
import '../services/supabase_service.dart';

class AdminDetailPelayananScreen extends StatefulWidget {
  final Map<String, dynamic> pasien;

  const AdminDetailPelayananScreen({super.key, required this.pasien});

  @override
  State<AdminDetailPelayananScreen> createState() =>
      _AdminDetailPelayananScreenState();
}

class _AdminDetailPelayananScreenState
    extends State<AdminDetailPelayananScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late bool _layananSelesai;

  // ================= DESIGN TOKENS =================
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _bgInner = Color(0xFFFFF0F5);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _accentLight = Color(0xFFE0F2F1);
  static const _cardRadius = 16.0;
  static const _cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
  ];

  @override
  void initState() {
    super.initState();
    _layananSelesai = widget.pasien['status_pelayanan'] == 'Selesai & Pulang' ||
                      widget.pasien['status'] == 'Selesai';
  }

  String _formatJam(String? jam) {
    if (jam == null || jam.isEmpty || jam == '-') return '-';
    final parts = jam.split(':');
    if (parts.length >= 2) return "${parts[0]}:${parts[1]}";
    return jam;
  }

  @override
  Widget build(BuildContext context) {
    final pasien = widget.pasien;

    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Pelayanan",
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= CARD INFO =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardRadius),
                boxShadow: _cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jenis Reservasi Pasien",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textPrimary),
                  ),
                  const SizedBox(height: 16),

                  /// FOTO + NAMA
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _accentLight,
                        child: Text(
                          ((pasien['nama_pasien'] ?? pasien['namaPasien'] ?? '-')[0]).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: _accent),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("PASIEN", style: TextStyle(fontSize: 10, color: _textSecondary, letterSpacing: 1)),
                          Text(
                            pasien['nama_pasien'] ?? pasien['namaPasien'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// LAYANAN + JADWAL
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _bgInner,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text("LAYANAN", style: TextStyle(fontSize: 10, color: _textSecondary, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(
                                pasien['layanan'] ?? '-',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _bgInner,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text("JADWAL", style: TextStyle(fontSize: 10, color: _textSecondary, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(
                                "${pasien['tanggal'] ?? '-'}, ${_formatJam(pasien['jam'])}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ================= VERIFIKASI =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardRadius),
                boxShadow: _cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Verifikasi Layanan",
                    style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
                  ),
                  const SizedBox(height: 12),

                  /// CHECKBOX
                  GestureDetector(
                    onTap: () async {
                      if (!_layananSelesai && widget.pasien['id'] != null) {
                        try {
                          await _supabaseService.updateReservasi(
                            widget.pasien['id'].toString(),
                            {'status_pelayanan': 'Diproses'},
                          );
                          setState(() {
                            _layananSelesai = true;
                          });
                          Navigator.pushNamed(context, '/admin_pasien');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal update status: $e")),
                          );
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _layananSelesai ? _accentLight : _bgInner,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _layananSelesai ? _accent : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _layananSelesai ? _accent : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _layananSelesai ? _accent : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: _layananSelesai
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Layanan sedang/telah dilakukan",
                              style: TextStyle(fontWeight: FontWeight.w500, color: _textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// BUTTON LANJUT PEMBAYARAN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _layananSelesai
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminDetailPembayaranScreen(pasien: pasien),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        "Lanjutkan ke Pembayaran",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}