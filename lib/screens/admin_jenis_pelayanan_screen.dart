import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_tambah_jenis_pelayanan_screen.dart';
import 'admin_edit_pelayanan_screen.dart';
import '../mock_data.dart';
import 'admin_chat_list_screen.dart';

class AdminJenisPelayananScreen extends StatefulWidget {
  const AdminJenisPelayananScreen({super.key});

  @override
  State<AdminJenisPelayananScreen> createState() =>
      _AdminJenisPelayananScreenState();
}

class _AdminJenisPelayananScreenState
    extends State<AdminJenisPelayananScreen> {

  int selectedTab = 0; // 0 = Klinik, 1 = Home Care

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
          "Jenis Pelayanan",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Container(
        color: const Color(0xFFE6B8BE),
        child: Column(
          children: [

            /// ===== TAB =====
            Row(
              children: [
                _tabItem("Layanan Klinik", 0),
                _tabItem("Layanan Home Care", 1),
              ],
            ),

            const SizedBox(height: 10),

            /// ===== LIST DARI MOCK DATA =====
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _filteredList(),
              ),
            ),

            /// ===== BUTTON TAMBAH =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AdminTambahJenisPelayananScreen(),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah Jenis Pemeriksaan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5F5F),
                  ),
                ),
              ),
            )
          ],
        ),
      ),

      bottomNavigationBar: _bottomNav(context),
    );
  }

  /// ===== FILTER DATA =====
  List<Widget> _filteredList() {
    final kategori = selectedTab == 0 ? "Klinik" : "Home Care";

    final data = MockDatabase.layananList
        .where((e) => e.kategori == kategori)
        .toList();

    if (data.isEmpty) {
      return [
        const Center(child: Text("Belum ada data")),
      ];
    }

    return data.map((layanan) {
      return _card(layanan);
    }).toList();
  }

  /// ===== CARD =====
  Widget _card(JenisPelayanan layanan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4C6CC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                layanan.nama,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              Row(
                children: [

                  /// EDIT
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminEditPelayananScreen(
                            layanan: layanan,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    child: const Icon(Icons.edit, size: 16),
                  ),

                  const SizedBox(width: 8),

                  /// DELETE
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        MockDatabase.layananList.remove(layanan);
                      });
                    },
                    child: const Icon(Icons.delete, size: 16),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 6),

          Text(layanan.deskripsi,
              style: const TextStyle(fontSize: 11)),

          const SizedBox(height: 8),

          Text(layanan.harga,
              style: const TextStyle(fontWeight: FontWeight.bold)),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              layanan.kategori,
              style: const TextStyle(fontSize: 10),
            ),
          )
        ],
      ),
    );
  }

  /// ===== TAB =====
  Widget _tabItem(String title, int index) {
    final isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// ===== NAV =====
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
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Pasien"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}