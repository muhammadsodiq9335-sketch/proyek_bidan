import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'admin_jadwal_detail_reservasi_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminJadwalScreen extends StatefulWidget {
  const AdminJadwalScreen({super.key});

  @override
  State<AdminJadwalScreen> createState() => _AdminJadwalScreenState();
}

class _AdminJadwalScreenState extends State<AdminJadwalScreen> {
  DateTime _displayMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  static const List<String> _monthNames = [
    'JANUARI','FEBRUARI','MARET','APRIL','MEI','JUNI',
    'JULI','AGUSTUS','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER'
  ];

  @override
  void initState() {
    super.initState();

    if (MockDatabase.userReservations.isNotEmpty) {
      final first = MockDatabase.userReservations.first;
      final date = DateTime.parse(first['tanggal']);
      _selectedDate = date;
      _displayMonth = date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIso = _toIso(_selectedDate);

    final filtered = MockDatabase.userReservations.where((res) {
      return res['tanggal'] == selectedIso;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEECAD0),

      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          ),
        ),
        title: const Text(
          "JADWAL",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _calendarUI(),
              const SizedBox(height: 16),
              _header(),
              const SizedBox(height: 12),

              if (filtered.isEmpty)
                const Text("Belum ada reservasi"),

              ...filtered.map((res) => _card(res)),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _bottomNav(context),
    );
  }

  // ================= CALENDAR =================
  Widget _calendarUI() {
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

          _calendarGrid(),
        ],
      ),
    );
  }

  Widget _calendarGrid() {
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

        final isSelected =
            _selectedDate.day == date.day &&
            _selectedDate.month == date.month &&
            _selectedDate.year == date.year;

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1F7A8C) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
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
                  res['namaPasien'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("${_displayDate(res['tanggal'])} • ${res['jam']}"),
              ],
            ),
          ),

          const Spacer(),

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
                  ).then((_) => setState(() {}));
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
    return "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
  }

  String _displayDate(String iso) {
    final date = DateTime.parse(iso);
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
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: const Color(0xFF1F7A8C),
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminChatListScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminPasienScreen()),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()),
            );
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