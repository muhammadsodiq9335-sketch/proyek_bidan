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
  State<AdminTambahJenisPelayananScreen> createState() =>
      _AdminTambahJenisPelayananScreenState();
}

class _AdminTambahJenisPelayananScreenState
    extends State<AdminTambahJenisPelayananScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController jenisPelayananController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();

  String? selectedCategory; // Klinik / Home Care
  String? selectedTarget;   // Ibu / Anak
  bool _isLoading = false;

  @override
  void dispose() {
    jenisPelayananController.dispose();
    deskripsiController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  Future<void> _simpanData() async {
    if (jenisPelayananController.text.isEmpty ||
        deskripsiController.text.isEmpty ||
        hargaController.text.isEmpty ||
        selectedCategory == null ||
        selectedTarget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi semua data yang diperlukan!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'nama': jenisPelayananController.text,
        'deskripsi': deskripsiController.text,
        'harga': "Rp ${hargaController.text}",
        'kategori': selectedTarget == "Ibu" ? "Layanan Kesehatan Ibu" : "Layanan Kesehatan Anak",
        'is_home_care': selectedCategory == "Home Care",
      };

      await _supabaseService.tambahJenisPelayanan(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan ke database!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e")),
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
          "Tambah Jenis Layanan",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              "Detail Layanan Baru",
              "Isi form untuk menambahkan layanan baru",
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("KATEGORI TEMPAT"),
            const SizedBox(height: 10),
            _buildCategoryButtons(),
            const SizedBox(height: 20),
            _buildSectionTitle("TARGET PASIEN"),
            const SizedBox(height: 10),
            _buildTargetButtons(),
            const SizedBox(height: 20),
            _buildSectionTitle("JENIS PEMERIKSAAN"),
            const SizedBox(height: 10),
            _buildTextInput(
              controller: jenisPelayananController,
              hintText: "Contoh: USG, Imunisasi, dll",
              icon: Icons.healing_outlined,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("DESKRIPSI"),
            const SizedBox(height: 10),
            _buildTextInput(
              controller: deskripsiController,
              hintText: "Deskripsi layanan",
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("HARGA"),
            const SizedBox(height: 10),
            _buildPriceInput(),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _simpanData,
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Simpan"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _buildTargetButtons() {
    return Wrap(
      spacing: 10,
      children: [
        _chipTarget("Ibu"),
        _chipTarget("Anak"),
      ],
    );
  }

  Widget _chipTarget(String text) {
    final selected = selectedTarget == text;
    return GestureDetector(
      onTap: () => setState(() => selectedTarget = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.pinkAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.pinkAccent : Colors.black12),
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black)),
      ),
    );
  }

  /// ================= UI =================

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8D5E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold));
  }

  Widget _buildCategoryButtons() {
    return Wrap(
      spacing: 10,
      children: [
        _chip("Klinik"),
        _chip("Home Care"),
      ],
    );
  }

  Widget _chip(String text) {
    final selected = selectedCategory == text;

    return GestureDetector(
      onTap: () => setState(() => selectedCategory = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildPriceInput() {
    return TextField(
      controller: hargaController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixText: "Rp ",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// ================= NAV =================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,

      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: Colors.grey,

      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        }
        if (index == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
        }
        if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => AdminChatListScreen()));
        }
        if (index == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminPasienScreen()));
        }
        if (index == 4) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
        }
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