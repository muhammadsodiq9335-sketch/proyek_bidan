import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_jadwal_screen.dart';
import 'chat_screen.dart';
import '../mock_data.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_pasien_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC), // pink background
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
                    _scheduleCard("Dewi Lestari", "Imunisasi Bayi", "08.00"),
                    const SizedBox(height: 12),
                    _scheduleCard("Maya Putri", "Pijat Bayi", "10.00"),
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
      children: [
        const Text(
          "MORA",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4F72),
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.grey,
          child: const Icon(Icons.person, color: Colors.white),
        )
      ],
    ),
  );
}

  // ================= RESERVATION =================
  Widget _reservationCard(BuildContext context) {
    // Ambil reservasi yang menunggu persetujuan
    final pending = MockDatabase.userReservations
        .where((r) => r['status'] == 'Menunggu Persetujuan')
        .toList();
    final hasPending = pending.isNotEmpty;
    final first = hasPending ? pending.first : null;

    return Container(
      width: double.infinity,
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
              hasPending ? "PERLU TINDAKAN" : "TIDAK ADA ANTRIAN",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasPending ? "Permintaan\nReservasi Baru" : "Semua Reservasi\nTelah Ditangani",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            hasPending
                ? "${first!['namaPasien'] ?? 'Pasien'} mengajukan ${first['layanan']} untuk pukul ${first['jam']} pada ${first['tanggal']}."
                : "Tidak ada reservasi yang menunggu konfirmasi saat ini.",
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (hasPending) ...[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  first['status'] = 'Dikonfirmasi';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reservasi berhasil dikonfirmasi!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAED581),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Konfirmasi Reservasi"),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminJadwalScreen()),
              ),
              child: const Text(
                "Lihat Detail",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1B2E35)),
              ),
            ),
          ],
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
        color: Colors.black54,
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E6C3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 10),
          const Text("8", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text("Pasien Dikonfirmasi Hari Ini"),
          ),
          const Text("HARI INI", style: TextStyle(fontSize: 10))
        ],
      ),
    );
  }

  // ================= JADWAL HEADER =================
  Widget _jadwalHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "JADWAL MENDATANG",
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminJadwalScreen(),
              ),
            );
          },
          child: const Text(
            "Cek Kalender →",
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // ================= SCHEDULE CARD =================
  Widget _scheduleCard(String name, String service, String time) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E6C3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // tanggal
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: const [
                Text("APRIL", style: TextStyle(fontSize: 9)),
                Text("24", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(service, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14),
                    const SizedBox(width: 4),
                    Text(time),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "CONFIRMED",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminJadwalScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen(isAdmin: true)),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminPengaturanScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminPasienScreen()),
          );
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