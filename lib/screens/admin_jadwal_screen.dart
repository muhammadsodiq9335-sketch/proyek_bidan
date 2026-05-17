import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_jadwal_detail_reservasi_screen.dart';

class AdminJadwalScreen extends StatefulWidget {
  const AdminJadwalScreen({super.key});

  @override
  State<AdminJadwalScreen> createState() => _AdminJadwalScreenState();
}

class _AdminJadwalScreenState extends State<AdminJadwalScreen> {
  DateTime _displayMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Map<String, dynamic>>> _reservasiFuture;

  // ================= DESIGN TOKENS =================
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _bgInner = Color(0xFFFFF0F5);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _accentLight = Color(0xFFF8E1E9);
  static const _cardRadius = 16.0;
  static const _cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
  ];

  static const List<String> _monthNames = [
    'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
    'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _displayMonth = now;
    _reservasiFuture = _supabaseService.getReservasi();
  }

  void _refreshData() {
    setState(() {
      _reservasiFuture = _supabaseService.getReservasi();
    });
  }

  String _formatJam(String? jam) {
    if (jam == null || jam.isEmpty || jam == '-') return '-';
    final parts = jam.split(':');
    if (parts.length >= 2) return "${parts[0]}:${parts[1]}";
    return jam;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIso = _toIso(_selectedDate);

    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false),
        ),
        title: const Text(
          "Jadwal",
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _reservasiFuture,
          builder: (context, snapshot) {
            final allReservations = snapshot.data ?? [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            final filtered = allReservations.where((res) {
              return res['tanggal'] == selectedIso;
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _calendarUI(allReservations),
                  const SizedBox(height: 16),
                  _header(),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(color: _accent),
                    )
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          const Text("Belum ada reservasi", style: TextStyle(color: _textSecondary, fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    ...filtered.map((res) => _card(res)),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  // ================= CALENDAR =================
  Widget _calendarUI(List<Map<String, dynamic>> allReservations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: _textPrimary,
                ),
              ),
              Row(
                children: [
                  _calNavButton(Icons.chevron_left, () {
                    setState(() {
                      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
                    });
                  }),
                  const SizedBox(width: 4),
                  _calNavButton(Icons.chevron_right, () {
                    setState(() {
                      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
                    });
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Day("SEN"), _Day("SEL"), _Day("RAB"),
              _Day("KAM"), _Day("JUM"), _Day("SAB"), _Day("MIN"),
            ],
          ),
          const SizedBox(height: 8),
          _calendarGrid(allReservations),
        ],
      ),
    );
  }

  Widget _calNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _bgInner,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: _textPrimary),
      ),
    );
  }

  Widget _calendarGrid(List<Map<String, dynamic>> allReservations) {
    final days = _buildMonthDays(_displayMonth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, i) {
        final date = days[i];
        if (date == null) return const SizedBox();

        final dateIso = _toIso(date);
        final isSelected =
            _selectedDate.day == date.day &&
            _selectedDate.month == date.month &&
            _selectedDate.year == date.year;

        final hasPending = allReservations.any((res) =>
          res['tanggal'] == dateIso && res['status'] == 'Menunggu Persetujuan'
        );

        final hasConfirmed = allReservations.any((res) =>
          res['tanggal'] == dateIso && (res['status'] == 'Dikonfirmasi' || res['status'] == 'Selesai')
        );

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _accent : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : _textPrimary,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasPending)
                      Container(
                        margin: const EdgeInsets.only(top: 2, right: 1),
                        width: 4, height: 4,
                        decoration: const BoxDecoration(color: Color(0xFFFF9800), shape: BoxShape.circle),
                      ),
                    if (hasConfirmed)
                      Container(
                        margin: const EdgeInsets.only(top: 2, left: 1),
                        width: 4, height: 4,
                        decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= HEADER =================
  Widget _header() {
    final bulan = _monthNames[_displayMonth.month - 1];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _accentLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_note_rounded, size: 18, color: _accent),
          const SizedBox(width: 8),
          Text(
            "Reservasi Bulan $bulan",
            style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _card(Map<String, dynamic> res) {
    final isConfirmed = res['status'] == 'Dikonfirmasi' || res['status'] == 'Selesai';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _bgInner,
            child: const Icon(Icons.person_outline, color: _textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  res['nama_pasien'] ?? res['namaPasien'] ?? 'Pasien',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_displayDate(res['tanggal'])} • ${_formatJam(res['jam'])}",
                  style: const TextStyle(fontSize: 12, color: _textSecondary),
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
                  color: res['status'] == 'Dikonfirmasi' || res['status'] == 'Selesai'
                      ? const Color(0xFFE8F5E9)
                      : (res['status'] == 'Ditolak' || res['status'] == 'Dibatalkan'
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFFFF3E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  res['status']?.toString().toUpperCase() ?? "PENDING",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    color: res['status'] == 'Dikonfirmasi' || res['status'] == 'Selesai'
                        ? const Color(0xFF2E7D32)
                        : (res['status'] == 'Ditolak' || res['status'] == 'Dibatalkan'
                            ? Colors.red
                            : const Color(0xFFE65100)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminJadwalDetailReservasiScreen(data: res),
                    ),
                  ).then((_) => _refreshData());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Detail",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HELPER =================
  String _toIso(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _displayDate(String? iso) {
    if (iso == null || iso.toString().isEmpty) return "-";
    final date = DateTime.tryParse(iso.toString()) ?? DateTime.now();
    return "${date.day} ${_monthNames[date.month - 1]} ${date.year}";
  }

  List<DateTime?> _buildMonthDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final start = first.weekday - 1;
    return List.generate(start + daysInMonth, (i) {
      if (i < start) return null;
      return DateTime(month.year, month.month, i - start + 1);
    });
  }

  // ================= NAV =================
 Widget _bottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        /// 🔥 STYLE BARU
        selectedItemColor: const Color(0xFFC2185B),
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
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
          }
          if (index == 1) {
            // Already here
          }
          if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin_chat_list');
          }
          if (index == 3) {
            Navigator.pushReplacementNamed(context, '/admin_pembayaran');
          }
          if (index == 4) {
            Navigator.pushReplacementNamed(context, '/admin_pengaturan');
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
            icon: Icon(Icons.payment),
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

class _Day extends StatelessWidget {
  final String text;
  const _Day(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, color: Color(0xFF607D8B), fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}