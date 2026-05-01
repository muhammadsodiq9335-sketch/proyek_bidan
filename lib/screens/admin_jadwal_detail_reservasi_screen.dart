import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_screen.dart';

class AdminJadwalDetailReservasiScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const AdminJadwalDetailReservasiScreen({
    super.key,
    required this.data,
  });

  @override
  State<AdminJadwalDetailReservasiScreen> createState() =>
      _AdminJadwalDetailReservasiScreenState();
}

class _AdminJadwalDetailReservasiScreenState
    extends State<AdminJadwalDetailReservasiScreen> {

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF2C6CB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Reservasi",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= PROFILE =================
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
                    child: const Icon(Icons.person, size: 40),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    data['namaPasien'] ?? '-',
                    style: const TextStyle(
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
                    child: const Text("Pasien"),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          "Alamat belum tersedia",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= DETAIL =================
            _infoBox(
              icon: Icons.calendar_today,
              title: "TANGGAL",
              value: _formatDate(data['tanggal']),
            ),

            const SizedBox(height: 12),

            _infoBox(
              icon: Icons.access_time,
              title: "WAKTU",
              value: data['jam'] ?? '-',
            ),

            const SizedBox(height: 12),

            _infoBox(
              icon: Icons.note,
              title: "JENIS RESERVASI",
              value: data['layanan'] ?? '-',
            ),

            const SizedBox(height: 20),

            // ================= BUTTON TERIMA =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    data['status'] = 'Dikonfirmasi';
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Terima Reservasi"),
              ),
            ),

            const SizedBox(height: 12),

            // ================= BUTTON LAIN =================
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text("Ganti Jadwal"),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        data['status'] = 'Ditolak';
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Tolak"),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: _bottomNav(context, 1),
    );
  }

  // ================= INFO BOX =================
  Widget _infoBox({
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
          Icon(icon),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ================= FORMAT DATE =================
  String _formatDate(String iso) {
    final date = DateTime.parse(iso);

    const bulan = [
      'JANUARI','FEBRUARI','MARET','APRIL','MEI','JUNI',
      'JULI','AGUSTUS','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER'
    ];

    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

  // ================= NAV =================
  Widget _bottomNav(BuildContext context, int index) {
    return BottomNavigationBar(
      currentIndex: index,
      selectedItemColor: const Color(0xFF1B5E20),
      onTap: (i) {
        switch (i) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminJadwalScreen()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Pasien"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}