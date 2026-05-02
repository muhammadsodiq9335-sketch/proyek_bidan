import 'package:flutter/material.dart';

// SESUAIKAN IMPORT PROJECT KAMU
import 'admin_jadwal_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_tambah_bidan_screen.dart';
import 'admin_edit_bidan_screen.dart';
import '../mock_data.dart';
import 'admin_chat_list_screen.dart';

class AdminCekProfilBidanScreen extends StatefulWidget {
  const AdminCekProfilBidanScreen({super.key});

  @override
  State<AdminCekProfilBidanScreen> createState() =>
      _AdminCekProfilBidanScreenState();
}

class _AdminCekProfilBidanScreenState
    extends State<AdminCekProfilBidanScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE6CF),

      /// ===== APPBAR =====
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

      /// ===== BODY =====
      body: Container(
        color: const Color(0xFFE6B8BE),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ===== BUTTON TAMBAH =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminTambahBidanScreen(),
                      ),
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah Bidan Baru"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ===== TITLE =====
              const Text(
                "Daftar Bidan Tersedia",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Tim Kebidanan MommyCare",
                style: TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 16),

              /// ===== LIST BIDAN =====
              if (MockDatabase.bidanList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Belum ada data bidan"),
                  ),
                )
              else
                Column(
                  children: List.generate(
                    MockDatabase.bidanList.length,
                    (index) {
                      final bidan = MockDatabase.bidanList[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E8C8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [

                            /// FOTO
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

                            /// INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    bidan.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    bidan.str,
                                    style:
                                        const TextStyle(fontSize: 11),
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [

                                      /// ===== EDIT =====
                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AdminEditBidanScreen(
                                                isEdit: true,
                                                index: index,
                                                data: {
                                                  "nama": bidan.nama,
                                                  "nik": bidan.nik,
                                                  "nip": bidan.nip,
                                                  "str": bidan.str,
                                                  "hp": bidan.hp,
                                                  "alamat": bidan.alamat,
                                                },
                                              ),
                                            ),
                                          );
                                          setState(() {});
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.edit, size: 14),
                                            SizedBox(width: 4),
                                            Text("Edit",
                                                style: TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      /// ===== HAPUS =====
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            MockDatabase.bidanList
                                                .removeAt(index);
                                          });
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete,
                                                size: 14,
                                                color: Colors.red),
                                            SizedBox(width: 4),
                                            Text(
                                              "Hapus",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                              ),
                                            ),
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
                  ),
                ),
            ],
          ),
        ),
      ),

      /// ===== BOTTOM NAV (JANGAN DIUBAH) =====
      bottomNavigationBar: _bottomNav(context),
    );
  }

  /// ===== BOTTOM NAV =====
  Widget _bottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        /// 🔥 STYLE BARU
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: const Color(0xFFB0BEC5),

        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          letterSpacing: 0.5,
        ),

        /// 🔥 NAVIGASI (TETAP PUNYA KAMU)
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
          }
          if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
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

        /// 🔥 ICON (SAMA, TAPI SUDAH IKUT WARNA)
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Jadwal",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: "Pembayaran",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Pengaturan",
          ),
        ],
      ),
    );
  }
}