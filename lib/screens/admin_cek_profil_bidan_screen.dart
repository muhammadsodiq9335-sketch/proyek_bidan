import 'package:flutter/material.dart';

// SESUAIKAN DENGAN PROJECT KAMU
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_tambah_bidan_screen.dart';
import 'bidan_data.dart';

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
              if (BidanData.bidanList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Belum ada data bidan"),
                  ),
                )
              else
                Column(
                  children: List.generate(
                    BidanData.bidanList.length,
                    (index) {
                      final bidan = BidanData.bidanList[index];

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
                                    bidan["nama"] ?? "-",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    bidan["str"] ?? "-",
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
                                                  AdminTambahBidanScreen(
                                                isEdit: true,
                                                index: index,
                                                data: bidan,
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
                                            BidanData.bidanList
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

      /// ===== BOTTOM NAV =====
      bottomNavigationBar: _bottomNav(context, 3),
    );
  }

  /// ===== BOTTOM NAV =====
  Widget _bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF1B5E20),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const AdminDashboardScreen(),
              ),
            );
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const AdminJadwalScreen(),
              ),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const AdminPasienScreen(),
              ),
            );
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const AdminPengaturanScreen(),
              ),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(
            icon: Icon(Icons.people), label: "Pasien"),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}