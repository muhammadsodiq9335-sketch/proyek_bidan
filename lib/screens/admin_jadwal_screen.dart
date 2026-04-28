import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_deatail-reservasi_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'login_screen.dart';


class AdminJadwalScreen extends StatefulWidget {
  const AdminJadwalScreen({super.key});

  @override
  State<AdminJadwalScreen> createState() => _AdminJadwalScreenState();
}

class _AdminJadwalScreenState extends State<AdminJadwalScreen> {
  DateTime _displayMonth = DateTime(2026, 4, 1);
  DateTime _selectedDate = DateTime(2026, 4, 24);

  static const List<String> _monthNames = [
    'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
    'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFF8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCalendarCard(),
                    const SizedBox(height: 20),
                    _buildSectionLabel(),
                    const SizedBox(height: 16),
                    _buildReservationCard(
                      name: 'Megawati',
                      date: '24 APRIL • 09.00',
                      status: 'TERKONFIRMASI',
                      statusColor: const Color(0xFF81C784),
                    ),
                    const SizedBox(height: 12),
                    _buildReservationCard(
                      name: 'Dewi Lestari',
                      date: '24 APRIL • 08.00',
                      status: 'TERKONFIRMASI',
                      statusColor: const Color(0xFF81C784),
                    ),
                    const SizedBox(height: 12),
                    _buildReservationCard(
                      name: 'Maya Putri',
                      date: '24 APRIL • 10.00',
                      status: 'PENDING',
                      statusColor: const Color(0xFFFFB74D),
                    ),
                    const SizedBox(height: 12),
                    _buildReservationCard(
                      name: 'Fuji Furab',
                      date: '24 APRIL • 11.00',
                      status: 'PENDING',
                      statusColor: const Color(0xFFFFB74D),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      color: const Color(0xFFD8F5E0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'JADWAL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E5939),
              letterSpacing: 1.2,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Color(0xFF2E5939)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final dayLabels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD3DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E3D27),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih tanggal untuk melihat jadwal reservasi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF66786F),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildMonthButton(Icons.arrow_back_ios, () => _changeMonth(-1)),
                  const SizedBox(width: 8),
                  _buildMonthButton(Icons.arrow_forward_ios, () => _changeMonth(1)),
                ],
              )
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9EAD9A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF2E5939)),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final days = _buildMonthDays(_displayMonth);
    final rows = (days.length / 7).ceil();

    return Column(
      children: [
        for (var row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: Center(
                      child: _buildDayCell(days[row * 7 + col]),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  List<DateTime?> _buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startOffset = firstDay.weekday == 7 ? 6 : firstDay.weekday - 1; // Mon start
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;

    return List<DateTime?>.generate(totalCells, (index) {
      final dayNumber = index - startOffset + 1;
      if (index < startOffset || dayNumber > daysInMonth) {
        return null;
      }
      return DateTime(month.year, month.month, dayNumber);
    });
  }

  Widget _buildDayCell(DateTime? date) {
    if (date == null) {
      return const SizedBox(height: 38);
    }

    final isSelected = _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF81C784) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF324B3D),
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _changeMonth(int diff) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + diff, 1);
    });
  }

  Widget _buildSectionLabel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'JADWAL HARIAN',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF8F6B22),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'RESERVASI BULAN APRIL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E5939),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard({
    required String name,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBEE6C8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Color(0xFF2E5939), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF1B3B2B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF607D62),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor.withOpacity(1.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminJadwalDetailReservasiScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
  return BottomNavigationBar(
    currentIndex: 1,
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF1B5E20),
    unselectedItemColor: const Color(0xFF9E9E9E),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Beranda',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Jadwal',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        label: 'Pasien',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Pengaturan',
      ),
    ],
    onTap: (index) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
          break;

        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminJadwalScreen(),
            ),
          );
          break;

        case 2:
          // sementara belum ada halaman pasien
          break;

        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminPengaturanScreen(),
            ),
          );
          break;
      }
    },
  );
}
}