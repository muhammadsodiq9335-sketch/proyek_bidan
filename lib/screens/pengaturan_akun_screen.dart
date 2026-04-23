import 'package:flutter/material.dart';
import '../mock_data.dart';

class PengaturanAkunScreen extends StatefulWidget {
  const PengaturanAkunScreen({super.key});

  @override
  State<PengaturanAkunScreen> createState() => _PengaturanAkunScreenState();
}

class _PengaturanAkunScreenState extends State<PengaturanAkunScreen> {
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (MockDatabase.currentUser != null) {
      _namaController.text = MockDatabase.currentUser!.nama;
      _alamatController.text = MockDatabase.currentUser!.alamat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Pengaturan Akun', style: TextStyle(color: Color(0xFF1B2E35), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Color(0xFF1B2E35)),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
          TextButton(
            onPressed: () {
              if (MockDatabase.currentUser != null) {
                // Simulasi simpan data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil berhasil diperbarui')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF00897B), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInputLabel('Nama Lengkap'),
            _buildTextField(_namaController, 'Nama Anda'),
            const SizedBox(height: 16),
            _buildInputLabel('Email'),
            _buildReadOnlyField(MockDatabase.currentUser?.email ?? '-'),
            const SizedBox(height: 16),
            _buildInputLabel('Alamat'),
            _buildTextField(_alamatController, 'Alamat Lengkap', maxLines: 3),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Tambahkan logika ganti password di sini
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Ganti Password', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF546E7A)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black38)),
    );
  }
}
