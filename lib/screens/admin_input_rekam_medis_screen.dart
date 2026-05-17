import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:intl/intl.dart';

class AdminInputRekamMedisScreen extends StatefulWidget {
  final Map<String, dynamic> reservasi;
  const AdminInputRekamMedisScreen({super.key, required this.reservasi});

  @override
  State<AdminInputRekamMedisScreen> createState() => _AdminInputRekamMedisScreenState();
}

class _AdminInputRekamMedisScreenState extends State<AdminInputRekamMedisScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  // Controllers
  final _hphtController = TextEditingController();
  final _hplController = TextEditingController();
  final _usiaController = TextEditingController();
  final _bbController = TextEditingController();
  final _tensiController = TextEditingController();
  final _tfuController = TextEditingController();
  final _djjController = TextEditingController();
  final _posisiController = TextEditingController();
  final _keluhanController = TextEditingController();
  final _diagnosaController = TextEditingController();
  final _tindakanController = TextEditingController();

  DateTime? _selectedHpht;
  DateTime? _selectedHpl;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _keluhanController.text = widget.reservasi['keluhan'] ?? '';
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getRekamMedisByReservasi(widget.reservasi['id']);
      if (data != null) {
        setState(() {
          if (data['hpht'] != null) {
            _selectedHpht = DateTime.parse(data['hpht']);
            _hphtController.text = DateFormat('dd/MM/yyyy').format(_selectedHpht!);
          }
          if (data['hpl'] != null) {
            _selectedHpl = DateTime.parse(data['hpl']);
            _hplController.text = DateFormat('dd/MM/yyyy').format(_selectedHpl!);
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
        });
      }
    } catch (e) {
      debugPrint("Error load rekam medis: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateHpl(DateTime hpht) {
    // Rumus Naegele: HPHT + 7 hari - 3 bulan + 1 tahun
    // Atau simpelnya + 280 hari
    setState(() {
      _selectedHpl = hpht.add(const Duration(days: 280));
      _hplController.text = DateFormat('dd/MM/yyyy').format(_selectedHpl!);
      
      // Hitung Usia Kehamilan
      final diff = DateTime.now().difference(hpht).inDays;
      final weeks = diff ~/ 7;
      final days = diff % 7;
      _usiaController.text = "$weeks Minggu $days Hari";
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final data = {
        'reservasi_id': widget.reservasi['id'],
        'user_id': widget.reservasi['user_id'],
        'bidan_id': widget.reservasi['bidan_id'],
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
      };

      await _supabaseService.tambahRekamMedis(data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rekam medis berhasil disimpan'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFC2185B);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Input Rekam Medis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: accentColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientInfo(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Pemeriksaan Kehamilan (ANC)'),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildDateField('HPHT (Hari Pertama Haid Terakhir)', _hphtController, (date) {
                      setState(() {
                        _selectedHpht = date;
                        _hphtController.text = DateFormat('dd/MM/yyyy').format(date);
                        _calculateHpl(date);
                      });
                    }),
                    _buildTextField('HPL (Hari Perkiraan Lahir)', _hplController, readOnly: true, icon: Icons.event_available),
                    _buildTextField('Usia Kehamilan', _usiaController, readOnly: true, icon: Icons.timer),
                  ]),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Tanda Vital & Fisik'),
                  const SizedBox(height: 12),
                  _buildCard([
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Berat Badan (kg)', _bbController, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Tensi (mmHg)', _tensiController, hint: '110/70')),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('TFU (cm)', _tfuController, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('DJJ (bpm)', _djjController, keyboardType: TextInputType.number)),
                      ],
                    ),
                    _buildTextField('Posisi Janin', _posisiController, hint: 'Kepala Bawah / Sungsang'),
                  ]),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Catatan Medis'),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildTextField('Keluhan', _keluhanController, maxLines: 2),
                    _buildTextField('Diagnosa', _diagnosaController, maxLines: 2),
                    _buildTextField('Tindakan / Obat', _tindakanController, maxLines: 2),
                  ]),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Simpan Rekam Medis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFCE4EC),
            child: const Icon(Icons.person, color: Color(0xFFC2185B)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.reservasi['nama_pasien'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(widget.reservasi['layanan'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFC2185B)));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, IconData? icon, int maxLines = 1, TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon != null ? Icon(icon, size: 20) : null,
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, Function(DateTime) onPicked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
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
              if (date != null) onPicked(date);
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
