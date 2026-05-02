import 'package:flutter/material.dart';
import '../mock_data.dart';

class AdminEditPelayananScreen extends StatefulWidget {
  final JenisPelayanan layanan;

  const AdminEditPelayananScreen({
    super.key,
    required this.layanan,
  });

  @override
  State<AdminEditPelayananScreen> createState() =>
      _AdminEditPelayananScreenState();
}

class _AdminEditPelayananScreenState extends State<AdminEditPelayananScreen> {

  String selectedCategory = 'Klinik';
  late TextEditingController jenisController;
  late TextEditingController deskripsiController;
  late TextEditingController hargaController;

  @override
  void initState() {
    super.initState();

    /// 🔥 ISI DATA DARI MOCK
    jenisController =
        TextEditingController(text: widget.layanan.nama);
    deskripsiController =
        TextEditingController(text: widget.layanan.deskripsi);
    hargaController = TextEditingController(
        text: widget.layanan.harga.replaceAll("Rp ", ""));

    selectedCategory = widget.layanan.kategori;
  }

  @override
  void dispose() {
    jenisController.dispose();
    deskripsiController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  void _updatePelayanan() {
    if (jenisController.text.isEmpty ||
        deskripsiController.text.isEmpty ||
        hargaController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi data layanan terlebih dahulu')),
      );
      return;
    }

    /// 🔥 UPDATE DATA (TANPA UBAH UI)
    widget.layanan.nama = jenisController.text;
    widget.layanan.deskripsi = deskripsiController.text;
    widget.layanan.harga = "Rp ${hargaController.text}";
    widget.layanan.kategori = selectedCategory;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data layanan berhasil diperbarui')),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Jenis Layanan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFF1B5E20),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),

      /// ⚠️ UI KAMU SAMA PERSIS (TIDAK DIUBAH)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Layanan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'DETAIL DATA MASTER',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'KATEGORI LAYANAN',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _categoryButton('Klinik'),
                        const SizedBox(width: 12),
                        _categoryButton('Home Care'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'JENIS PELAYANAN',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: jenisController,
                      hintText: 'Konsultasi KB',
                      icon: Icons.medical_services_outlined,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'DESKRIPSI',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: deskripsiController,
                      hintText: 'Detail layanan',
                      icon: Icons.description_outlined,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'HARGA LAYANAN',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPriceField(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _updatePelayanan,
                child: const Text("Perbarui"),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// ===== SISANYA TIDAK DIUBAH =====
  Widget _categoryButton(String label) {
    final isSelected = selectedCategory == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00897B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF00897B) : const Color(0xFFE0E0E0),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF00897B)),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: hargaController,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 3,
      onTap: (index) {},
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Jadwal'),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
      ],
    );
  }
}