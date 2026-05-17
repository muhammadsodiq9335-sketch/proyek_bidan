import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AdminEditBidanScreen extends StatefulWidget {
  final Map<String, dynamic> bidanData;
  const AdminEditBidanScreen({super.key, required this.bidanData});
  @override
  State<AdminEditBidanScreen> createState() => _AdminEditBidanScreenState();
}

class _AdminEditBidanScreenState extends State<AdminEditBidanScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  late final TextEditingController namaC;
  late final TextEditingController nikC;
  late final TextEditingController nipC;
  late final TextEditingController strC;
  late final TextEditingController hpC;
  late final TextEditingController alamatC;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.bidanData['nama'] ?? '');
    nikC = TextEditingController(text: widget.bidanData['nik'] ?? '');
    nipC = TextEditingController(text: widget.bidanData['nip'] ?? '');
    strC = TextEditingController(text: (widget.bidanData['str'] ?? '').toString().replaceAll('No. STR: ', ''));
    hpC = TextEditingController(text: widget.bidanData['hp'] ?? '');
    alamatC = TextEditingController(text: widget.bidanData['alamat'] ?? '');
  }

  @override
  void dispose() { namaC.dispose(); nikC.dispose(); nipC.dispose(); strC.dispose(); hpC.dispose(); alamatC.dispose(); super.dispose(); }

  Future<void> _simpan() async {
    if (namaC.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama wajib diisi'))); return; }
    setState(() => _isLoading = true);
    try {
      await _supabaseService.updateBidan(widget.bidanData['id'].toString(), {'nama': namaC.text, 'nik': nikC.text, 'nip': nipC.text, 'str': 'No. STR: ${strC.text}', 'hp': hpC.text, 'alamat': alamatC.text});
      if (mounted) Navigator.pop(context);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'))); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Data Bidan', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
          child: Column(children: [
            CircleAvatar(radius: 36, backgroundColor: const Color(0xFFFFF0F5),
              child: Text(namaC.text.isNotEmpty ? namaC.text[0].toUpperCase() : '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _accent))),
            const SizedBox(height: 20),
            _inputField('Nama Lengkap', 'Contoh: Siti Aminah', namaC, Icons.person_outline),
            _inputField('NIK (KTP)', '16 Digit NIK', nikC, Icons.credit_card_outlined),
            _inputField('NIP', 'Nomor Induk Pegawai', nipC, Icons.badge_outlined),
            _inputField('Nomor STR', 'Surat Tanda Registrasi', strC, Icons.verified_outlined),
            _inputField('No. HP', '08xx xxxx xxxx', hpC, Icons.phone_outlined),
            _inputField('Alamat', 'Alamat lengkap', alamatC, Icons.location_on_outlined),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(foregroundColor: _textSecondary, side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Batal'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: _isLoading ? null : _simpan,
                style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController c, IconData icon) {
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary)),
      const SizedBox(height: 6),
      TextField(controller: c, decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: _accent), filled: true, fillColor: const Color(0xFFFFF0F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
    ]));
  }
}
