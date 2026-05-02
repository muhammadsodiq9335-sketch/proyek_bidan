import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_chat_list_screen.dart';
import '../mock_data.dart';

class AdminTambahJenisPelayananScreen extends StatefulWidget {
  const AdminTambahJenisPelayananScreen({super.key});

  @override
  State<AdminTambahJenisPelayananScreen> createState() =>
      _AdminTambahJenisPelayananScreenState();
}

class _AdminTambahJenisPelayananScreenState
    extends State<AdminTambahJenisPelayananScreen> {

  final TextEditingController jenisPelayananController =
      TextEditingController();
  final TextEditingController deskripsiController =
      TextEditingController();
  final TextEditingController hargaController =
      TextEditingController();

  String? selectedCategory;

  @override
  void dispose() {
    jenisPelayananController.dispose();
    deskripsiController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  /// 🔥 FIX UTAMA DI SINI
  void _simpanData() {
    if (jenisPelayananController.text.isEmpty ||
        deskripsiController.text.isEmpty ||
        hargaController.text.isEmpty ||
        selectedCategory == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi semua data yang diperlukan!")),
      );
      return;
    }

    /// ✅ TAMBAH KE MOCK DATABASE
    MockDatabase.layananList.add(
      JenisPelayanan(
        nama: jenisPelayananController.text,
        deskripsi: deskripsiController.text,
        harga: "Rp ${hargaController.text}",
        kategori: selectedCategory!,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data berhasil disimpan!")),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
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

            _buildSectionTitle("KATEGORI"),
            const SizedBox(height: 10),
            _buildCategoryButtons(),

            const SizedBox(height: 20),

            _buildSectionTitle("JENIS"),
            const SizedBox(height: 10),
            _buildTextInput(
              controller: jenisPelayananController,
              hintText: "Contoh: USG",
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _simpanData,
                    child: const Text("Simpan"),
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