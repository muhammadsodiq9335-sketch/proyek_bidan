import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _reservasiFuture;

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
  void initState() {
    super.initState();
    _reservasiFuture = _supabaseService.getReservasi();
  }

  void _refreshData() {
    setState(() {
      _reservasiFuture = _supabaseService.getReservasi();
    });
  }

  DateTime _safeParseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    return DateTime.tryParse(dateStr) ?? DateTime.now();
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return (month >= 1 && month <= 12) ? months[month] : '';
  }

  String _formatJam(String? jam) {
    if (jam == null || jam.isEmpty || jam == '-') return '-';
    final parts = jam.split(':');
    if (parts.length >= 2) {
      return "${parts[0]}:${parts[1]}";
    }
    return jam;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      bottomNavigationBar: _bottomNav(context, 0),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _reservasiFuture,
          builder: (context, snapshot) {
            final allReservations = snapshot.data ?? [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            if (isLoading) {
              return const Center(child: CircularProgressIndicator(color: _accent));
            }

            return Column(
              children: [
                _header(),
                Expanded(
                  child: RefreshIndicator(
                    color: _accent,
                    onRefresh: () async => _refreshData(),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _reservationCard(context, allReservations),
                          const SizedBox(height: 16),
                          _summaryCard(context, allReservations),
                          const SizedBox(height: 20),
                          _jadwalHeader(context),
                          const SizedBox(height: 10),
                          ..._getSchedules(allReservations).map((res) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _scheduleCard(
                                res['nama_pasien'] ?? res['namaPasien'] ?? 'Pasien',
                                res['layanan'] ?? '-',
                                res['jam'] ?? '-',
                                res['tanggal'] ?? '',
                              ),
                            );
                          }),
                          if (_getSchedules(allReservations).isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  Icon(Icons.event_available, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tidak ada jadwal mendatang",
                                    style: TextStyle(color: _textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
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

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _accentLight,
                  borderRadius: BorderRadius.circular(10),
                  image: AuthService.currentUserProfile?.fotoUrl != null && AuthService.currentUserProfile!.fotoUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(AuthService.currentUserProfile!.fotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: AuthService.currentUserProfile?.fotoUrl == null || AuthService.currentUserProfile!.fotoUrl!.isEmpty
                    ? const Icon(Icons.local_hospital_rounded, color: _accent, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MORA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    "Admin Panel",
                    style: TextStyle(fontSize: 11, color: _textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/admin_laporan'),
                icon: const Icon(Icons.bar_chart_rounded, color: _accent, size: 24),
                tooltip: 'Laporan Pelayanan',
              ),
              const SizedBox(width: 4),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _bgInner,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_outline, color: _textSecondary, size: 20),
              ),
            ],
          ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
        border: Border(
          left: BorderSide(
            color: hasPending ? const Color(0xFFFF9800) : _accent,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasPending ? const Color(0xFFFFF3E0) : _accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hasPending ? "PERLU TINDAKAN" : "SEMUA DIPROSES",
                    style: TextStyle(
                      color: hasPending ? const Color(0xFFE65100) : _accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (hasPending)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${pending.length}",
                      style: const TextStyle(
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hasPending ? "Reservasi Baru Masuk" : "Tidak Ada Antrian",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasPending
                  ? "${first!['nama_pasien'] ?? first['namaPasien'] ?? 'Pasien'} • ${first['layanan']} • ${_formatJam(first['jam'])}"
                  : "Semua reservasi sudah ditangani.",
              style: const TextStyle(color: _textSecondary, fontSize: 13),
            ),
            if (hasPending) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin_jadwal');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Lihat Detail", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ],
        ),
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
      final isHandled = res['status'] == 'Dikonfirmasi' || res['status'] == 'Selesai';
      return isHandled &&
          itemDate.year == today.year &&
          itemDate.month == today.month &&
          itemDate.day == today.day;
    }).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _accentLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.calendar_today_outlined, size: 24, color: _accent),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "RINGKASAN HARI INI",
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$total Pasien Dikonfirmasi",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/admin_ringkasan'),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: _accent.withValues(alpha: 77)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Detail",
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ),
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
        if (dateA != dateB) return dateA.compareTo(dateB);
        return (a['jam'] ?? '').compareTo(b['jam'] ?? '');
      });
  }

  // ================= JADWAL =================
  Widget _scheduleCard(String name, String service, String time, String tanggal) {
    final date = _safeParseDate(tanggal);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${date.day}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 16),
                ),
                Text(
                  _getMonthName(date.month),
                  style: const TextStyle(fontSize: 10, color: _accent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
                const SizedBox(height: 2),
                Text(service, style: const TextStyle(fontSize: 12, color: _textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _bgInner,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: _textSecondary),
                const SizedBox(width: 4),
                Text(_formatJam(time), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TITLE =================
  Widget _jadwalHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "JADWAL MENDATANG",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: _textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/admin_jadwal'),
          child: const Text(
            "Lihat Semua",
            style: TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ================= NAV =================
  Widget _bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFC2185B),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/admin_jadwal');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/admin_chat_list');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/admin_pembayaran');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/admin_pengaturan');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}
