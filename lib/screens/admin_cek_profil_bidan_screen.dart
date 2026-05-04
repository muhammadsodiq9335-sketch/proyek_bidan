import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_tambah_bidan_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminCekProfilBidanScreen extends StatefulWidget {
  const AdminCekProfilBidanScreen({super.key});

  @override
  State<AdminCekProfilBidanScreen> createState() =>
      _AdminCekProfilBidanScreenState();
}

class _AdminCekProfilBidanScreenState
    extends State<AdminCekProfilBidanScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE6CF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cek Profil Bidan",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: const Color(0xFFE6B8BE),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminTambahBidanScreen(),
                      ),
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah Bidan Baru"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _supabaseService.getBidan(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final listBidan = snapshot.data ?? [];
                  if (listBidan.isEmpty) return const Center(child: Text("Belum ada data bidan"));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: listBidan.length,
                    itemBuilder: (context, index) {
                      final bidan = listBidan[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E8C8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bidan['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(bidan['str'] ?? '-', style: const TextStyle(fontSize: 11)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminTambahBidanScreen(
                                                isEdit: true,
                                                data: Map<String, String>.from(bidan.map((k, v) => MapEntry(k, v?.toString() ?? ''))),
                                              ),
                                            ),
                                          );
                                          setState(() {});
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.edit, size: 14),
                                            SizedBox(width: 4),
                                            Text("Edit", style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () async {
                                          final id = bidan['id'];
                                          if (id != null) {
                                            await _supabaseService.deleteBidan(id.toString());
                                            setState(() {});
                                          }
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete, size: 14, color: Colors.red),
                                            SizedBox(width: 4),
                                            Text("Hapus", style: TextStyle(fontSize: 12, color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
        if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
        if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPasienScreen()));
        if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
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