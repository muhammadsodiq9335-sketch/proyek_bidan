import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../mock_data.dart';

class AdminEditPelayananScreen extends StatefulWidget {
  final JenisPelayanan layanan;
  final String? serviceId;

  const AdminEditPelayananScreen({
    super.key,
    required this.layanan,
    this.serviceId,
  });

  @override
  State<AdminEditPelayananScreen> createState() =>
      _AdminEditPelayananScreenState();
}

class _AdminEditPelayananScreenState extends State<AdminEditPelayananScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController jenisController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();

  String? selectedType; // Klinik / Home Care
  String? selectedKategori; // 4 Categories
  bool _isLoading = false;

  final List<String> categories = [
    "Kesehatan Ibu",
    "Kesehatan Anak",
    "Komplementer Ibu",
    "Komplementer Bayi"
  ];

  @override
  void initState() {
    super.initState();
    jenisController.text = widget.layanan.nama;
    deskripsiController.text = widget.layanan.deskripsi;
    hargaController.text = widget.layanan.harga.replaceAll(RegExp(r'[^0-9]'), '');
    selectedKategori = widget.layanan.kategori;
    
    // Defaulting selectedType based on category or common sense if not provided
    // Ideally is_home_care should be passed in but we can infer for now
    if (selectedKategori?.contains("Komplementer") ?? false) {
      selectedType = "Home Care";
    } else {
      selectedType = "Klinik";
    }
  }

  @override
  void dispose() {
    jenisController.dispose();
    deskripsiController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  Future<void> _updatePelayanan() async {
    if (jenisController.text.isEmpty ||
        deskripsiController.text.isEmpty ||
        hargaController.text.isEmpty ||
        selectedType == null ||
        selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data layanan')),
      );
      return;
    }

    if (widget.serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID Layanan tidak ditemukan!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'nama': jenisController.text,
        'deskripsi': deskripsiController.text,
        'harga': int.parse(hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'kategori': selectedKategori,
        'is_home_care': selectedType == "Home Care",
      };

      await _supabaseService.updateJenisPelayanan(widget.serviceId!, data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data layanan berhasil diperbarui')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Jenis Layanan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("TIPE LAYANAN"),
            const SizedBox(height: 10),
            _buildTypeButtons(),
            const SizedBox(height: 20),
            _buildSectionTitle("KATEGORI LAYANAN"),
            const SizedBox(height: 10),
            _buildKategoriDropdown(),
            const SizedBox(height: 20),
            _buildSectionTitle("NAMA LAYANAN"),
            const SizedBox(height: 10),
            _buildTextField(
              controller: jenisController,
              hintText: 'Konsultasi KB',
              icon: Icons.medical_services_outlined,
            ),
            const SizedBox(height: 18),
            _buildSectionTitle("DESKRIPSI"),
            const SizedBox(height: 10),
            _buildTextField(
              controller: deskripsiController,
              hintText: 'Detail layanan',
              icon: Icons.description_outlined,
              maxLines: 5,
            ),
            const SizedBox(height: 18),
            _buildSectionTitle("HARGA LAYANAN"),
            const SizedBox(height: 10),
            _buildPriceField(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePelayanan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold));
  }

  Widget _buildTypeButtons() {
    return Wrap(
      spacing: 10,
      children: [
        _chipType("Klinik"),
        _chipType("Home Care"),
      ],
    );
  }

  Widget _chipType(String text) {
    final selected = selectedType == text;
    return GestureDetector(
      onTap: () => setState(() => selectedType = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.teal : Colors.black12),
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _buildKategoriDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedKategori,
          hint: const Text("Pilih Kategori"),
          isExpanded: true,
          items: categories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => selectedKategori = val);
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF00897B)),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: hargaController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixText: "Rp ",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}