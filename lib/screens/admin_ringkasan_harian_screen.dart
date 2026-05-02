import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_detail_pelayanan_screen.dart';

class AdminRingkasanHarianScreen extends StatefulWidget {
  const AdminRingkasanHarianScreen({super.key});

  @override
  State<AdminRingkasanHarianScreen> createState() =>
      _AdminRingkasanHarianScreenState();
}

class _AdminRingkasanHarianScreenState
    extends State<AdminRingkasanHarianScreen> {

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    /// ================= FILTER DATA =================
    final confirmedToday = MockDatabase.userReservations.where((e) {
      final date = DateTime.parse(e['tanggal']);
      return e['status'] == 'Dikonfirmasi' &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();

    final allToday = MockDatabase.userReservations.where((e) {
      final date = DateTime.parse(e['tanggal']);
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      bottomNavigationBar: _bottomNav(context, 0),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        title: const Text(
          "Ringkasan Harian",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            const Text(
              "Daftar Pasien Hari Ini",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// DATE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 6),
                  Text(_formatDate(now)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD8E6C3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.calendar_today_outlined),
                      Text("HARI INI", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${confirmedToday.length}",
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("Pasien Dikonfirmasi Hari Ini"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST TITLE
            const Text(
              "Jadwal Antrian Hari Ini",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            /// LIST
            ...allToday.map((e) {

              final status = e['statusPelayanan'] ?? 'Menunggu';

              Color statusColor;
              String statusText;

              if (status == 'Selesai & Pulang') {
                statusColor = Colors.green.shade200;
                statusText = "Selesai";
              } else if (status == 'Diproses') {
                statusColor = Colors.orange.shade200;
                statusText = "Diproses";
              } else {
                statusColor = Colors.blue.shade100;
                statusText = "Menunggu";
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E6C3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [

                    /// AVATAR
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),

                    const SizedBox(width: 12),

                    /// TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['namaPasien'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e['layanan'].toUpperCase(),
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14),
                              const SizedBox(width: 4),
                              Text(e['jam']),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// RIGHT
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        /// STATUS
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// BUTTON
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminDetailPelayananScreen(pasien: e),
                              ),
                            );

                            /// 🔥 REFRESH FIX
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                status == 'Selesai & Pulang'
                                    ? const Color(0xFF0D47A1)
                                    : const Color(0xFFD1DCE5),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Lihat Detail",
                            style: TextStyle(
                              fontSize: 11,
                              color: status == 'Selesai & Pulang'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember'
    ];
    return "${date.day} ${bulan[date.month]} ${date.year}";
  }

  Widget _bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 1:
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => AdminJadwalScreen()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => AdminChatListScreen()));
            break;
          case 3:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => AdminPasienScreen()));
            break;
          case 4:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => AdminPengaturanScreen()));
            break;
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