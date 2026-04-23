import 'package:flutter/material.dart';

// IMPORT SCREEN LAIN (WAJIB ADA DI PROJECT KAMU)
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_screen.dart';

class AdminJadwalDetailReservasiScreen extends StatelessWidget {
  const AdminJadwalDetailReservasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2C6CB),

      appBar: AppBar(
        title: const Text("Detail Reservasi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),

      /// ===== BODY =====
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ===== CARD PROFILE =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE99AA3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Fuji Furaba",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "26 Tahun",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "Jl. Bandung, Kota Malang, Jawa Timur",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.phone_android, size: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ===== DETAIL =====
            _buildInfoBox(
              icon: Icons.calendar_today,
              title: "TANGGAL",
              value: "24 April 2026",
            ),

            const SizedBox(height: 12),

            _buildInfoBox(
              icon: Icons.access_time,
              title: "WAKTU",
              value: "08.00",
            ),

            const SizedBox(height: 12),

            _buildInfoBox(
              icon: Icons.note,
              title: "JENIS RESERVASI",
              value: "Pijat Bayi",
            ),

            const SizedBox(height: 20),

            /// ===== BUTTON TERIMA =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Terima Reservasi"),
              ),
            ),

            const SizedBox(height: 12),

            /// ===== BUTTON BAWAH =====
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text("Ganti Jadwal"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close),
                    label: const Text("Tolak"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),

      /// ===== BOTTOM NAVIGATION =====
      bottomNavigationBar: _buildBottomNav(context, 1),
    );
  }

  /// ===== WIDGET INFO BOX =====
  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E8C8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10)),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// ===== BOTTOM NAV =====
  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1B5E20),
      unselectedItemColor: const Color(0xFF9E9E9E),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Jadwal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Pasien',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Pengaturan',
        ),
      ],
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminJadwalScreen(),
              ),
            );
            break;

          case 2:
            // halaman pasien (nanti)
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminPengaturanScreen(),
              ),
            );
            break;
        }
      },
    );
  }
}