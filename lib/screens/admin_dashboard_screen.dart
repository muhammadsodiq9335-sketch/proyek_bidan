import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../services/supabase_service.dart';
import 'admin_jadwal_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_ringkasan_harian_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  DateTime _safeParseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    return DateTime.tryParse(dateStr) ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      bottomNavigationBar: _bottomNav(context, 0),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _supabaseService.getReservasi(), // Ambil semua reservasi untuk admin
          builder: (context, snapshot) {
            final allReservations = snapshot.data ?? [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _header(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _reservationCard(context, allReservations),
                          const SizedBox(height: 20),
                          _sectionTitle("RINGKASAN HARIAN"),
                          const SizedBox(height: 10),
                          _summaryCard(context, allReservations),
                          const SizedBox(height: 20),
                          _jadwalHeader(context),
                          const SizedBox(height: 10),
                          ..._getSchedules(allReservations).map((res) {
                            return Column(
                              children: [
                                _scheduleCard(
                                  res['nama_pasien'] ?? res['namaPasien'] ?? 'Pasien',
                                  res['layanan'] ?? '-',
                                  res['jam'] ?? '-',
                                  res['tanggal'] ?? '',
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return (month >= 1 && month <= 12) ? months[month] : '';
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF8FAFC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1B4F72)),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "MORA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4F72),
                ),
              ),
            ],
          ),
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          )
        ],
      ),
    );
  }

  // ================= RESERVATION =================
  Widget _reservationCard(BuildContext context, List<Map<String, dynamic>> reservations) {
    final pending = reservations
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
              hasPending ? "PERLU TINDAKAN" : "SEMUA SUDAH DIPROSES",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasPending ? "Reservasi Baru Masuk" : "Tidak Ada Antrian",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            hasPending
                ? "${first!['nama_pasien'] ?? first['namaPasien'] ?? 'Pasien'} • ${first['layanan']} • ${first['jam']}"
                : "Semua reservasi sudah ditangani.",
          ),
          const SizedBox(height: 12),
          if (hasPending)
            ElevatedButton(
              onPressed: () async {
                // Implementasi konfirmasi langsung ke Supabase bisa ditambahkan nanti
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Buka menu Jadwal untuk konfirmasi")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAED581),
              ),
              child: const Text("Lihat Detail"),
            ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summaryCard(BuildContext context, List<Map<String, dynamic>> reservations) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final total = reservations.where((res) {
      final date = _safeParseDate(res['tanggal']);
      final itemDate = DateTime(date.year, date.month, date.day);

      return res['status'] == 'Dikonfirmasi' &&
          itemDate.year == today.year &&
          itemDate.month == today.month &&
          itemDate.day == today.day;
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E6C3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 22,
            color: Color(0xFF1B4F72),
          ),
          const SizedBox(height: 10),
          Text(
            "$total",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pasien Dikonfirmasi Hari Ini",
                style: TextStyle(fontSize: 12),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminRingkasanHarianScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1DCE5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Lihat Detail",
                  style: TextStyle(
                    color: Color(0xFF1B4F72),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= DATA =================
  List<Map<String, dynamic>> _getSchedules(List<Map<String, dynamic>> reservations) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(const Duration(days: 1));

    return reservations.where((res) {
      final date = _safeParseDate(res['tanggal']);
      final itemDate = DateTime(date.year, date.month, date.day);

      return res['status'] == 'Dikonfirmasi' &&
          !itemDate.isBefore(today) &&
          !itemDate.isAfter(maxDate);
    }).toList()
      ..sort((a, b) {
        final dateA = _safeParseDate(a['tanggal']);
        final dateB = _safeParseDate(b['tanggal']);

        if (dateA != dateB) {
          return dateA.compareTo(dateB);
        }

        return (a['jam'] ?? '').compareTo(b['jam'] ?? '');
      });
  }

  // ================= JADWAL =================
  Widget _scheduleCard(String name, String service, String time, String tanggal) {
    final date = _safeParseDate(tanggal);

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
                Text(
                  _getMonthName(date.month),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${date.day}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminJadwalScreen()),
            );
          },
          child: const Text("Lihat Semua"),
        )
      ],
    );
  }

  // ================= NAV =================
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminJadwalScreen()));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminChatListScreen()));
            break;
          case 3:
            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPasienScreen()));
            break;
          case 4:
            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPengaturanScreen()));
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