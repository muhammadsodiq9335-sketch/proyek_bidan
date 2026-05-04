import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../mock_data.dart';

class AdminTambahBidanScreen extends StatefulWidget {
  final bool isEdit;
  final int? index;
  final Map<String, String>? data;
  const AdminTambahBidanScreen({super.key, this.isEdit = false, this.index, this.data});
  @override
  State<AdminTambahBidanScreen> createState() => _AdminTambahBidanScreenState();
}

class _AdminTambahBidanScreenState extends State<AdminTambahBidanScreen> {
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  final namaC = TextEditingController();
  final nikC = TextEditingController();
  final nipC = TextEditingController();
  final strC = TextEditingController();
  final hpC = TextEditingController();
  final alamatC = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.data != null) {
      namaC.text = widget.data!["nama"] ?? "";
      nikC.text = widget.data!["nik"] ?? "";
      nipC.text = widget.data!["nip"] ?? "";
      strC.text = widget.data!["str"]?.replaceAll("No. STR: ", "") ?? "";
      hpC.text = widget.data!["hp"] ?? "";
      alamatC.text = widget.data!["alamat"] ?? "";
    }
  }

  Future<void> simpanData() async {
    if (namaC.text.isEmpty || strC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama & STR wajib diisi")));
      return;
    }
    setState(() => _isLoading = true);
    final dataBaru = {"nama": namaC.text, "nik": nikC.text, "nip": nipC.text, "str": "No. STR: ${strC.text}", "hp": hpC.text, "alamat": alamatC.text};
    final supabaseService = SupabaseService();
    try {
      if (widget.isEdit && widget.data != null && widget.data!['id'] != null) {
        await supabaseService.updateBidan(widget.data!['id']!, dataBaru);
      } else {
        await supabaseService.tambahBidan(dataBaru);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        title: Text(widget.isEdit ? "Edit Data Bidan" : "Tambah Bidan Baru", style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
          child: Column(children: [
            // Upload foto placeholder
            Container(width: 120, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(16), border: Border.all(color: _accent.withOpacity(0.2), width: 1.5, strokeAlign: BorderSide.strokeAlignCenter)),
              child: Column(children: const [
                Icon(Icons.add_a_photo_rounded, size: 36, color: _accent),
                SizedBox(height: 8),
                Text("Upload Foto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _textPrimary)),
                Text("Foto formal 3x4", textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: _textSecondary)),
              ]),
            ),
            const SizedBox(height: 20),
            _input("Nama Lengkap", "Contoh: Siti Aminah, S.Tr.Keb", namaC, Icons.person_outline),
            _input("NIK (KTP)", "16 Digit Nomor Induk Kependudukan", nikC, Icons.credit_card_outlined),
            _input("NIP (Pegawai)", "Nomor Induk Pegawai", nipC, Icons.badge_outlined),
            _input("Nomor STR", "Surat Tanda Registrasi", strC, Icons.verified_outlined),
            _input("No. HP", "08xx xxxx xxxx", hpC, Icons.phone_outlined),
            _input("Alamat Lengkap", "Jl. Raya Utama No.12", alamatC, Icons.location_on_outlined),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(foregroundColor: _textSecondary, side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Batal"))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: _isLoading ? null : simpanData,
                style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.isEdit ? "Update Data" : "Simpan Data Bidan", style: const TextStyle(fontWeight: FontWeight.bold)))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _input(String label, String hint, TextEditingController c, IconData icon) {
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