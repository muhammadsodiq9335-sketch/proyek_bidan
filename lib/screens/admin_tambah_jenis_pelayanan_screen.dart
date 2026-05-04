import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_chat_list_screen.dart';

class AdminTambahJenisPelayananScreen extends StatefulWidget {
  const AdminTambahJenisPelayananScreen({super.key});
  @override
  State<AdminTambahJenisPelayananScreen> createState() => _AdminTambahJenisPelayananScreenState();
}

class _AdminTambahJenisPelayananScreenState extends State<AdminTambahJenisPelayananScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController jenisPelayananController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  String? selectedType;
  String? selectedKategori;
  bool _isLoading = false;

  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  final List<String> categories = ["Kesehatan Ibu", "Kesehatan Anak", "Komplementer Ibu", "Komplementer Bayi"];

  @override
  void dispose() { jenisPelayananController.dispose(); deskripsiController.dispose(); hargaController.dispose(); super.dispose(); }

  Future<void> _simpanData() async {
    if (jenisPelayananController.text.isEmpty || deskripsiController.text.isEmpty || hargaController.text.isEmpty || selectedType == null || selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi semua data yang diperlukan!")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final data = {'nama': jenisPelayananController.text, 'deskripsi': deskripsiController.text, 'harga': int.parse(hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')), 'kategori': selectedKategori, 'is_home_care': selectedType == "Home Care"};
      await _supabaseService.tambahJenisPelayanan(data);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan!")));
      Navigator.pop(context);
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e"))); }
    finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text("Tambah Jenis Layanan", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.medical_services_rounded, size: 20, color: _accent)),
                const SizedBox(width: 10),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Detail Layanan Baru", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
                  SizedBox(height: 2),
                  Text("Isi form untuk menambahkan layanan baru", style: TextStyle(fontSize: 11, color: _textSecondary)),
                ])),
              ]),
            ),
            const SizedBox(height: 20),
            _sectionTitle("TIPE LAYANAN"),
            const SizedBox(height: 10),
            Row(children: [_chipType("Klinik"), const SizedBox(width: 10), _chipType("Home Care")]),
            const SizedBox(height: 20),
            _sectionTitle("KATEGORI LAYANAN"),
            const SizedBox(height: 10),
            _buildKategoriDropdown(),
            const SizedBox(height: 20),
            _sectionTitle("NAMA LAYANAN"),
            const SizedBox(height: 10),
            _textInput(controller: jenisPelayananController, hintText: "Contoh: USG, Imunisasi, dll", icon: Icons.healing_outlined),
            const SizedBox(height: 20),
            _sectionTitle("DESKRIPSI"),
            const SizedBox(height: 10),
            _textInput(controller: deskripsiController, hintText: "Deskripsi layanan", icon: Icons.description_outlined, maxLines: 3),
            const SizedBox(height: 20),
            _sectionTitle("HARGA"),
            const SizedBox(height: 10),
            _priceInput(),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(foregroundColor: _textSecondary, side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Batal"))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(onPressed: _isLoading ? null : _simpanData,
                style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)))),
            ]),
          ]),
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _buildKategoriDropdown() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: selectedKategori, hint: const Text("Pilih Kategori", style: TextStyle(fontSize: 14, color: _textSecondary)), isExpanded: true,
        items: categories.map((v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(),
        onChanged: (val) => setState(() => selectedKategori = val),
      )),
    );
  }

  Widget _chipType(String text) {
    final selected = selectedType == text;
    return GestureDetector(
      onTap: () => setState(() => selectedType = text),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(color: selected ? _accent : const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _accent : Colors.grey.shade300)),
        child: Text(text, style: TextStyle(color: selected ? Colors.white : _textPrimary, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary, letterSpacing: 0.5));
  }

  Widget _textInput({required TextEditingController controller, required String hintText, required IconData icon, int maxLines = 1}) {
    return TextField(controller: controller, maxLines: maxLines,
      decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: _accent), filled: true, fillColor: const Color(0xFFFFF0F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }

  Widget _priceInput() {
    return TextField(controller: hargaController, keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: "Contoh: 50000", hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixText: "Rp ", prefixStyle: const TextStyle(color: _accent, fontWeight: FontWeight.bold),
        filled: true, fillColor: const Color(0xFFFFF0F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, type: BottomNavigationBarType.fixed, selectedItemColor: _accent, unselectedItemColor: const Color(0xFFB0BEC5),
      onTap: (index) {
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => AdminChatListScreen()));
        if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPasienScreen()));
        if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}