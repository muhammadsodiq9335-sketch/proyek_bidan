import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'admin_jadwal_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _reservationCard(context),
                    const SizedBox(height: 20),

                    _sectionTitle("RINGKASAN HARIAN"),
                    const SizedBox(height: 10),
                    _summaryCard(),

                    const SizedBox(height: 20),

                    _jadwalHeader(context),
                    const SizedBox(height: 10),

                    ..._getSchedules().map((res) {
                      return Column(
                        children: [
                          _scheduleCard(
                            res['namaPasien'],
                            res['layanan'],
                            res['jam'],
                            res['tanggal'],
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF8FAFC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "MORA",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4F72),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          )
        ],
      ),
    );
  }

  // ================= RESERVATION =================
  Widget _reservationCard(BuildContext context) {
    final pending = MockDatabase.userReservations
        .where((r) => r['status'] == 'Menunggu Persetujuan')
        .toList();

    final hasPending = pending.isNotEmpty;
    final first = hasPending ? pending.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7999F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: hasPending ? Colors.brown : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hasPending ? "PERLU TINDAKAN" : "AMAN",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            hasPending ? "Reservasi Baru Masuk" : "Tidak Ada Antrian",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            hasPending
                ? "${first!['namaPasien']} • ${first['layanan']} • ${first['jam']}"
                : "Semua reservasi sudah ditangani.",
          ),

          const SizedBox(height: 12),

          if (hasPending)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  first?['status'] = 'Dikonfirmasi';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAED581),
              ),
              child: const Text("Konfirmasi"),
            ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summaryCard() {
    final total = MockDatabase.userReservations.where((res) {
      return res['status'] == 'Dikonfirmasi';
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E6C3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 10),
          Text(
            "$total",
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text("Pasien Dikonfirmasi")),
        ],
      ),
    );
  }

  // ================= DATA =================
  List<Map<String, dynamic>> _getSchedules() {
    final data = MockDatabase.userReservations.where((res) {
      return res['status'] == 'Dikonfirmasi';
    }).toList();

    data.sort((a, b) {
      final dateA = DateTime.parse(a['tanggal']);
      final dateB = DateTime.parse(b['tanggal']);
      return dateA.compareTo(dateB);
    });

    return data.take(3).toList();
  }

  // ================= JADWAL =================
  Widget _scheduleCard(
      String name, String service, String time, String tanggal) {
    final date = DateTime.parse(tanggal);

    const bulan = [
      'JAN','FEB','MAR','APR','MEI','JUN',
      'JUL','AGS','SEP','OKT','NOV','DES'
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E6C3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(bulan[date.month - 1],
                    style: const TextStyle(fontSize: 9)),
                Text("${date.day}",
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(service),
                const SizedBox(height: 4),
                Text("🕒 $time"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TITLE =================
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _jadwalHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "JADWAL MENDATANG",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
          },
          child: const Text("Lihat Semua"),
        )
      ],
    );
  }

  // ================= NAV =================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
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