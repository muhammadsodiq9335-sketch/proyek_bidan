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
  
  // Controllers Rekam Medis (Dibuat di initState agar aman)
  late TextEditingController _hphtController;
  late TextEditingController _hplController;
  late TextEditingController _usiaController;
  late TextEditingController _bbController;
  late TextEditingController _tensiController;
  late TextEditingController _tfuController;
  late TextEditingController _djjController;
  late TextEditingController _posisiController;
  late TextEditingController _keluhanController;
  late TextEditingController _diagnosaController;
  late TextEditingController _tindakanController;
  late TextEditingController _rencanaController;

  late bool _layananSelesai;
  bool _isSaving = false;

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

  DateTime? _selectedHpht;
  DateTime? _selectedHpl;

  @override
  void initState() {
    super.initState();
    // Inisialisasi semua controller
    _hphtController = TextEditingController();
    _hplController = TextEditingController();
    _usiaController = TextEditingController();
    _bbController = TextEditingController();
    _tensiController = TextEditingController();
    _tfuController = TextEditingController();
    _djjController = TextEditingController();
    _posisiController = TextEditingController();
    _keluhanController = TextEditingController();
    _diagnosaController = TextEditingController();
    _tindakanController = TextEditingController();
    _rencanaController = TextEditingController();

    _layananSelesai = widget.pasien['status_pelayanan'] == 'Selesai & Pulang' ||
                      widget.pasien['status'] == 'Selesai';
    
    _loadExistingMedicalData();
    _keluhanController.text = widget.pasien['keluhan'] ?? '';
  }

  @override
  void dispose() {
    _hphtController.dispose();
    _hplController.dispose();
    _usiaController.dispose();
    _bbController.dispose();
    _tensiController.dispose();
    _tfuController.dispose();
    _djjController.dispose();
    _posisiController.dispose();
    _keluhanController.dispose();
    _diagnosaController.dispose();
    _tindakanController.dispose();
    _rencanaController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMedicalData() async {
    try {
      final data = await _supabaseService.getRekamMedisByReservasi(widget.pasien['id']);
      if (data != null && mounted) {
        setState(() {
          if (data['hpht'] != null) {
            _selectedHpht = DateTime.parse(data['hpht']);
            _hphtController.text = _formatDateDisplay(_selectedHpht!);
          }
          if (data['hpl'] != null) {
            _selectedHpl = DateTime.parse(data['hpl']);
            _hplController.text = _formatDateDisplay(_selectedHpl!);
          }
          _usiaController.text = data['usia_kehamilan'] ?? '';
          _bbController.text = (data['berat_badan'] ?? '').toString();
          _tensiController.text = data['tensi'] ?? '';
          _tfuController.text = (data['tfu'] ?? '').toString();
          _djjController.text = (data['djj'] ?? '').toString();
          _posisiController.text = data['posisi_janin'] ?? '';
          _keluhanController.text = data['keluhan'] ?? '';
          _diagnosaController.text = data['diagnosa'] ?? '';
          _tindakanController.text = data['tindakan'] ?? '';
          _rencanaController.text = data['rencana_selanjutnya'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error load rekam medis: $e");
    }
  }

  String _formatDateDisplay(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _calculateHpl(DateTime hpht) {
    setState(() {
      _selectedHpl = hpht.add(const Duration(days: 280));
      _hplController.text = _formatDateDisplay(_selectedHpl!);
      
      final diff = DateTime.now().difference(hpht).inDays;
      final weeks = diff ~/ 7;
      final days = diff % 7;
      _usiaController.text = "$weeks Minggu $days Hari";
    });
  }

  Future<void> _saveAndProceed() async {
    setState(() => _isSaving = true);
    try {
      final medData = {
        'reservasi_id': widget.pasien['id'],
        'user_id': widget.pasien['user_id'],
        'bidan_id': widget.pasien['bidan_id'],
        'hpht': _selectedHpht?.toIso8601String().split('T')[0],
        'hpl': _selectedHpl?.toIso8601String().split('T')[0],
        'usia_kehamilan': _usiaController.text,
        'berat_badan': double.tryParse(_bbController.text),
        'tensi': _tensiController.text,
        'tfu': double.tryParse(_tfuController.text),
        'djj': double.tryParse(_djjController.text),
        'posisi_janin': _posisiController.text,
        'keluhan': _keluhanController.text,
        'diagnosa': _diagnosaController.text,
        'tindakan': _tindakanController.text,
        'rencana_selanjutnya': _rencanaController.text,
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
          SnackBar(content: Text('Gagal menyimpan rekam medis: $e'), backgroundColor: Colors.red),
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
                                "Layanan sedang/telah dilakukan",
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
                        "Input Rekam Medis (EHR)",
                        style: TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      _buildDateField("HPHT (Hari Pertama Haid Terakhir)", _hphtController),
                      Row(
                        children: [
                          Expanded(child: _buildTextField("HPL (Perkiraan)", _hplController, readOnly: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField("Usia Hamil", _usiaController, readOnly: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildTextField("BB (kg)", _bbController, keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField("Tensi", _tensiController, hint: "110/70")),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildTextField("TFU (cm)", _tfuController, keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField("DJJ (bpm)", _djjController, keyboardType: TextInputType.number)),
                        ],
                      ),
                      _buildTextField("Posisi Janin", _posisiController, hint: "Kepala Bawah / Sungsang"),
                      _buildTextField("Keluhan Sekarang", _keluhanController, maxLines: 2),
                      _buildTextField("Diagnosa / Hasil", _diagnosaController, maxLines: 2),
                      _buildTextField("Tindakan / Terapi", _tindakanController, maxLines: 2),
                      const SizedBox(height: 8),
                      const Text(
                        "Rencana & Rekomendasi Selanjutnya",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField("Saran / Jadwal Kontrol Berikutnya", _rencanaController, maxLines: 3, hint: "Contoh: Kontrol lagi tgl 25 Mei, kurangi garam..."),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_layananSelesai && !_isSaving)
                            ? _saveAndProceed
                            : null,
                        icon: _isSaving 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(
                          _isSaving ? "Menyimpan..." : "Lanjutkan ke Pembayaran",
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, int maxLines = 1, TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController targetController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: targetController,
            readOnly: true,
            style: const TextStyle(fontSize: 13),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedHpht ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF004D40), // Hijau pekat
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF1B2E35),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() {
                  _selectedHpht = date;
                  targetController.text = _formatDateDisplay(date);
                  _calculateHpl(date);
                });
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today, size: 16),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
