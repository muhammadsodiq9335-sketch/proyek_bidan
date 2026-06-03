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
  final _formKey = GlobalKey<FormState>();
  
  // Controllers Rekam Medis (SOAP)
  final TextEditingController _subjectiveController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _assessmentController = TextEditingController();
  final TextEditingController _planController = TextEditingController();

  late bool _layananSelesai;
  bool _isSaving = false;

  bool get _isAlreadyPaid => widget.pasien['status'] == 'Selesai' ||
                             widget.pasien['status_pelayanan'] == 'Selesai & Pulang';

  // SOAP terkunci jika sudah lanjut ke pembayaran atau sudah lunas
  bool get _isSoapLocked =>
      widget.pasien['status'] == 'Selesai' ||
      widget.pasien['status_pelayanan'] == 'Selesai & Pulang' ||
      widget.pasien['status'] == 'Menunggu Pembayaran' ||
      widget.pasien['status'] == 'Menunggu Konfirmasi Pembayaran';

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
    
    _loadExistingMedicalData();
    _subjectiveController.text = widget.pasien['keluhan'] ?? '';
  }

  @override
  void dispose() {
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMedicalData() async {
    try {
      final data = await _supabaseService.getRekamMedisByReservasi(widget.pasien['id']);
      if (data != null && mounted) {
        setState(() {
          _subjectiveController.text = data['subjective'] ?? '';
          _objectiveController.text = data['objective'] ?? '';
          _assessmentController.text = data['assessment'] ?? '';
          _planController.text = data['plan'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error load rekam medis: $e");
    }
  }

  Future<void> _saveAndProceed() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua kolom pemeriksaan SOAP wajib diisi dan tidak boleh kosong!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final medData = {
        'reservasi_id': widget.pasien['id'],
        'user_id': widget.pasien['user_id'],
        'bidan_id': widget.pasien['bidan_id'],
        'subjective': _subjectiveController.text.trim(),
        'objective': _objectiveController.text.trim(),
        'assessment': _assessmentController.text.trim(),
        'plan': _planController.text.trim(),
      };

      await _supabaseService.tambahRekamMedis(medData);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDetailPembayaranScreen(pasien: widget.pasien),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan detail pemeriksaan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Detail Pelayanan",
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _accentLight,
                          backgroundImage: (pasien['foto_url'] != null && pasien['foto_url'].toString().trim().isNotEmpty)
                              ? NetworkImage(pasien['foto_url'].toString())
                              : null,
                          child: (pasien['foto_url'] == null || pasien['foto_url'].toString().trim().isEmpty)
                              ? Text(
                                  ((pasien['nama_pasien'] ?? pasien['namaPasien'] ?? '-')[0]).toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: _accent),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("PASIEN", style: TextStyle(fontSize: 10, color: _textSecondary, letterSpacing: 1)),
                            Text(
                              pasien['nama_pasien'] ?? pasien['namaPasien'] ?? '-',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Builder(
                              builder: (context) {
                                final String patientId = pasien['user_id'] != null 
                                    ? pasien['user_id'].toString().substring(0, 8).toUpperCase() 
                                    : '-';
                                final String tipeLayanan = pasien['tipe_layanan'] ?? 'Klinik';
                                final bool isHomeCare = tipeLayanan.toLowerCase().contains('home');
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                      ),
                                      child: Text(
                                        "ID: #$patientId",
                                        style: const TextStyle(fontSize: 9, color: _textSecondary, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isHomeCare 
                                            ? const Color(0xFFE3F2FD) 
                                            : const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isHomeCare 
                                              ? const Color(0xFF90CAF9) 
                                              : const Color(0xFFA5D6A7),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        tipeLayanan,
                                        style: TextStyle(
                                          fontSize: 9, 
                                          color: isHomeCare 
                                              ? const Color(0xFF1565C0) 
                                              : const Color(0xFF2E7D32), 
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _bgInner,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("BIDAN", style: TextStyle(fontSize: 10, color: _textSecondary, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            pasien['nama_bidan'] ?? 'Bidan Belum Ditentukan',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 12),
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
                    GestureDetector(
                      onTap: () async {
                        if (_isAlreadyPaid) return;
                        if (!_layananSelesai && widget.pasien['id'] != null) {
                          try {
                            await _supabaseService.updateReservasi(
                              widget.pasien['id'].toString(),
                              {'status_pelayanan': 'Diproses'},
                            );
                            setState(() {
                              _layananSelesai = true;
                            });
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
                                "Layanan telah dilakukan",
                                style: TextStyle(fontWeight: FontWeight.w500, color: _textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_layananSelesai) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        "Input Detail Pemeriksaan (SOAP)",
                        style: TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Subjective (S) - Keluhan & Riwayat Pasien",
                        _subjectiveController,
                        maxLines: 3,
                        hint: "Masukkan keluhan atau kondisi yang dirasakan pasien saat ini...",
                        readOnly: _isSoapLocked,
                      ),
                      _buildTextField(
                        "Objective (O) - Hasil Pemeriksaan Fisik & Vital Sign",
                        _objectiveController,
                        maxLines: 3,
                        hint: "Tensi, berat badan, suhu, detak jantung, dll...",
                        readOnly: _isSoapLocked,
                      ),
                      _buildTextField(
                        "Assessment (A) - Diagnosa & Analisa Medis",
                        _assessmentController,
                        maxLines: 3,
                        hint: "Diagnosa medis atau hasil analisis kondisi pasien...",
                        readOnly: _isSoapLocked,
                      ),
                      _buildTextField(
                        "Plan (P) - Rencana Tindakan & Rekomendasi",
                        _planController,
                        maxLines: 3,
                        hint: "Rencana terapi, pemberian obat, saran, atau jadwal kontrol berikutnya...",
                        readOnly: _isSoapLocked,
                      ),
                    ],
                     const SizedBox(height: 24),
                     Builder(
                       builder: (context) {
                         final bool isAlreadyPaid = widget.pasien['status'] == 'Selesai' ||
                                                    widget.pasien['status_pelayanan'] == 'Selesai & Pulang';
                         return SizedBox(
                           width: double.infinity,
                           child: ElevatedButton.icon(
                             onPressed: isAlreadyPaid
                                 ? () {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(
                                         content: Text("Pembayaran untuk layanan ini telah selesai dilakukan."),
                                         backgroundColor: Colors.green,
                                       ),
                                     );
                                   }
                                 : ((_layananSelesai && !_isSaving)
                                     ? _saveAndProceed
                                     : null),
                             icon: _isSaving 
                               ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                               : Icon(isAlreadyPaid ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 18),
                             label: Text(
                               _isSaving 
                                 ? "Menyimpan..." 
                                 : (isAlreadyPaid ? "Pembayaran Selesai dilakukan" : "Lanjutkan ke Pembayaran"),
                               style: const TextStyle(fontWeight: FontWeight.bold),
                             ),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: isAlreadyPaid ? const Color(0xFF4CAF50) : _accent,
                               foregroundColor: Colors.white,
                               disabledBackgroundColor: Colors.grey.shade200,
                               padding: const EdgeInsets.symmetric(vertical: 14),
                               elevation: 0,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(12),
                               ),
                             ),
                           ),
                         );
                       }
                     ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, int maxLines = 1, TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary, fontFamily: 'Outfit'),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13),
            validator: (value) {
              if (!readOnly && (value == null || value.trim().isEmpty)) {
                return "Kolom ini wajib diisi dan tidak boleh kosong";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 1)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }


}
