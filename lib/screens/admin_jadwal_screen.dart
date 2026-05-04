import 'package:flutter/material.dart';
import '../mock_data.dart';
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

  static const List<String> _monthNames = [
    'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
    'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER'
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIso = _toIso(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFEECAD0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false),
        ),
        title: const Text(
          "JADWAL",
          style: TextStyle(color: Colors.black),
        ),
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
                    const Center(child: CircularProgressIndicator())
                  else if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Belum ada reservasi", style: TextStyle(color: Colors.black45)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF3),
        borderRadius: BorderRadius.circular(20),
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
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 18),
                    onPressed: () {
                      setState(() {
                        _displayMonth = DateTime(
                          _displayMonth.year,
                          _displayMonth.month - 1,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 18),
                    onPressed: () {
                      setState(() {
                        _displayMonth = DateTime(
                          _displayMonth.year,
                          _displayMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Day("SEN"),
              _Day("SEL"),
              _Day("RAB"),
              _Day("KAM"),
              _Day("JUM"),
              _Day("SAB"),
              _Day("MIN"),
            ],
          ),
          const SizedBox(height: 8),
          _calendarGrid(allReservations),
        ],
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

        // Cek apakah ada reservasi "Menunggu Persetujuan" di tanggal ini
        final hasPending = allReservations.any((res) => 
          res['tanggal'] == dateIso && res['status'] == 'Menunggu Persetujuan'
        );

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1F7A8C) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                if (hasPending)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
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
        color: const Color(0xFFFFF3C4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "RESERVASI BULAN $bulan",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _card(Map<String, dynamic> res) {
    final isConfirmed = res['status'] == 'Dikonfirmasi';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF5D8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  res['nama_pasien'] ?? res['namaPasien'] ?? 'Pasien',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("${_displayDate(res['tanggal'])} • ${res['jam']}"),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? Colors.blue.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isConfirmed ? "TERKONFIRMASI" : "PENDING",
                  style: TextStyle(
                    fontSize: 10,
                    color: isConfirmed ? Colors.blue : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminJadwalDetailReservasiScreen(data: res),
                    ),
                  ).then((_) => _refreshData());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Lihat Detail",
                    style: TextStyle(color: Colors.white, fontSize: 10),
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
        selectedItemColor: const Color(0xFF00897B),
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
            Navigator.pushNamedAndRemoveUntil(context, '/admin_jadwal', (route) => false);
          }
          if (index == 2) {
            Navigator.pushNamedAndRemoveUntil(context, '/admin_chat_list', (route) => false);
          }
          if (index == 3) {
            Navigator.pushNamedAndRemoveUntil(context, '/admin_pasien', (route) => false);
          }
          if (index == 4) {
            Navigator.pushNamedAndRemoveUntil(context, '/admin_pengaturan', (route) => false);
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
            icon: Icon(Icons.payments),
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
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ),
    );
  }
}