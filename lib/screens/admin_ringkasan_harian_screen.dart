import 'package:flutter/material.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_detail_pelayanan_screen.dart';
import '../services/supabase_service.dart';

class AdminRingkasanHarianScreen extends StatefulWidget {
  const AdminRingkasanHarianScreen({super.key});

  @override
  State<AdminRingkasanHarianScreen> createState() =>
      _AdminRingkasanHarianScreenState();
}

class _AdminRingkasanHarianScreenState
    extends State<AdminRingkasanHarianScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  DateTime _selectedDate = DateTime.now();

  // ================= DESIGN TOKENS =================
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _bgInner = Color(0xFFFFF0F5);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _accentLight = Color(0xFFE0F2F1);
  static const _cardRadius = 16.0;
  static const _cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
  ];

  @override
  Widget build(BuildContext context) {
    final now = _selectedDate;

    return Scaffold(
      backgroundColor: _bgScaffold,
      bottomNavigationBar: _bottomNav(context, 0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Ringkasan Harian",
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getReservasi(),
        builder: (context, snapshot) {
          final allReservations = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator(color: _accent));
          }

          final confirmedToday = allReservations.where((e) {
            final date = DateTime.tryParse(e['tanggal'] ?? '') ?? DateTime.now();
            final isHandled = e['status'] == 'Dikonfirmasi' || e['status'] == 'Selesai';
            return isHandled &&
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          }).toList();

          final allToday = allReservations.where((e) {
            final date = DateTime.tryParse(e['tanggal'] ?? '') ?? DateTime.now();
            final status = e['status'];
            final isExcluded = status == 'Ditolak' || status == 'Dibatalkan';
            return !isExcluded &&
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= DATE BADGE =================
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: _accent,
                              onPrimary: Colors.white,
                              onSurface: _textPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _accentLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: _accent),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(now),
                          style: const TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down_rounded, size: 16, color: _accent),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// ================= SUMMARY CARD =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(_cardRadius),
                    boxShadow: const [
                      BoxShadow(color: Color(0x30009688), blurRadius: 16, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            "${confirmedToday.length}",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pasien Dikonfirmasi",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (now.year == DateTime.now().year &&
                                      now.month == DateTime.now().month &&
                                      now.day == DateTime.now().day)
                                  ? "Hari Ini"
                                  : _formatDate(now),
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.trending_up_rounded, color: Colors.white54, size: 32),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// ================= QUEUE HEADER =================
                const Text(
                  "JADWAL ANTRIAN",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                if (allToday.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_available, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          const Text("Tidak ada antrian hari ini", style: TextStyle(color: _textSecondary)),
                        ],
                      ),
                    ),
                  )
                else
                  ...allToday.map((e) {
                    final status = e['status_pelayanan'] ?? e['statusPelayanan'] ?? 'Menunggu';
                    Color statusColor;
                    Color statusTextColor;
                    String statusText;

                    if (status == 'Selesai & Pulang') {
                      statusColor = const Color(0xFFE8F5E9);
                      statusTextColor = const Color(0xFF2E7D32);
                      statusText = "Selesai";
                    } else if (status == 'Diproses') {
                      statusColor = const Color(0xFFFFF3E0);
                      statusTextColor = const Color(0xFFE65100);
                      statusText = "Diproses";
                    } else {
                      statusColor = const Color(0xFFE3F2FD);
                      statusTextColor = const Color(0xFF1565C0);
                      statusText = "Menunggu";
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(_cardRadius),
                        boxShadow: _cardShadow,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: _bgInner,
                            backgroundImage: (e['foto_url'] != null && e['foto_url'].toString().trim().isNotEmpty)
                                ? NetworkImage(e['foto_url'].toString())
                                : null,
                            child: (e['foto_url'] == null || e['foto_url'].toString().trim().isEmpty)
                                ? const Icon(Icons.person_outline, color: _textSecondary)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e['nama_pasien'] ?? e['namaPasien'] ?? 'Pasien',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (e['layanan'] ?? '-').toString(),
                                  style: const TextStyle(fontSize: 12, color: _textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 13, color: _textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatJam(e['jam']),
                                      style: const TextStyle(fontSize: 12, color: _textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminDetailPelayananScreen(pasien: e),
                                    ),
                                  );
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _accent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Detail",
                                    style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
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
          );
        },
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

  String _formatJam(String? jam) {
    if (jam == null || jam.isEmpty || jam == '-') return '-';
    final parts = jam.split(':');
    if (parts.length >= 2) return "${parts[0]}:${parts[1]}";
    return jam;
  }

  Widget _bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFC2185B),
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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}
