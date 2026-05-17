import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/jenis_pelayanan.dart';

class AdminEditPelayananScreen extends StatefulWidget {
  final JenisPelayanan layanan;
  final String? serviceId;
  const AdminEditPelayananScreen({super.key, required this.layanan, this.serviceId});
  @override
  State<AdminEditPelayananScreen> createState() => _AdminEditPelayananScreenState();
}

class _AdminEditPelayananScreenState extends State<AdminEditPelayananScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController jenisController = TextEditingController();
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
  void initState() {
    super.initState();
    jenisController.text = widget.layanan.nama;
    deskripsiController.text = widget.layanan.deskripsi;
    hargaController.text = widget.layanan.harga.replaceAll(RegExp(r'[^0-9]'), '');
    selectedKategori = widget.layanan.kategori;
    if (selectedKategori?.contains("Komplementer") ?? false) { selectedType = "Home Care"; } else { selectedType = "Klinik"; }
  }

  @override
  void dispose() { jenisController.dispose(); deskripsiController.dispose(); hargaController.dispose(); super.dispose(); }

  Future<void> _updatePelayanan() async {
    if (jenisController.text.isEmpty || deskripsiController.text.isEmpty || hargaController.text.isEmpty || selectedType == null || selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data layanan'))); return;
    }
    if (widget.serviceId == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID Layanan tidak ditemukan!'))); return; }
    setState(() => _isLoading = true);
    try {
      final data = {'nama': jenisController.text, 'deskripsi': deskripsiController.text, 'harga': int.parse(hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')), 'kategori': selectedKategori, 'is_home_care': selectedType == "Home Care"};
      await _supabaseService.updateJenisPelayanan(widget.serviceId!, data);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data layanan berhasil diperbarui')));
      Navigator.pop(context);
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui: $e'))); }
    finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Jenis Layanan', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            _textInput(controller: jenisController, hintText: 'Konsultasi KB', icon: Icons.medical_services_outlined),
            const SizedBox(height: 18),
            _sectionTitle("DESKRIPSI"),
            const SizedBox(height: 10),
            _textInput(controller: deskripsiController, hintText: 'Detail layanan', icon: Icons.description_outlined, maxLines: 5),
            const SizedBox(height: 18),
            _sectionTitle("HARGA LAYANAN"),
            const SizedBox(height: 10),
            _priceField(),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(foregroundColor: _textSecondary, side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Batal"))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(onPressed: _isLoading ? null : _updatePelayanan,
                style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Simpan Perubahan", style: TextStyle(fontWeight: FontWeight.bold)))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary, letterSpacing: 0.5));

  Widget _chipType(String text) {
    final selected = selectedType == text;
    return GestureDetector(onTap: () => setState(() => selectedType = text),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(color: selected ? _accent : const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? _accent : Colors.grey.shade300)),
        child: Text(text, style: TextStyle(color: selected ? Colors.white : _textPrimary, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13))));
  }

  Widget _buildKategoriDropdown() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: selectedKategori, hint: const Text("Pilih Kategori", style: TextStyle(fontSize: 14, color: _textSecondary)), isExpanded: true,
        items: categories.map((v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(),
        onChanged: (val) => setState(() => selectedKategori = val))));
  }

  Widget _textInput({required TextEditingController controller, required String hintText, required IconData icon, int maxLines = 1}) {
    return TextFormField(controller: controller, maxLines: maxLines,
      decoration: InputDecoration(prefixIcon: Icon(icon, color: _accent, size: 18), hintText: hintText, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true, fillColor: const Color(0xFFFFF0F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }

  Widget _priceField() {
    return TextFormField(controller: hargaController, keyboardType: TextInputType.number,
      decoration: InputDecoration(prefixText: "Rp ", prefixStyle: const TextStyle(color: _accent, fontWeight: FontWeight.bold),
        filled: true, fillColor: const Color(0xFFFFF0F5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }
}