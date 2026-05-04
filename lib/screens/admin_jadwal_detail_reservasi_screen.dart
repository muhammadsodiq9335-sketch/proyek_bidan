import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../services/supabase_service.dart';

String _getFirstName(String fullName) {
  final nameWithoutTitle = fullName.split(',')[0];
  return nameWithoutTitle.split(' ')[0];
}

class AdminJadwalDetailReservasiScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const AdminJadwalDetailReservasiScreen({
    super.key,
    required this.data,
  });

  @override
  State<AdminJadwalDetailReservasiScreen> createState() =>
      _AdminJadwalDetailReservasiScreenState();
}

class _AdminJadwalDetailReservasiScreenState
    extends State<AdminJadwalDetailReservasiScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int selectedBidan = -1;
  List<Map<String, dynamic>> _bidanList = [];
  bool _isLoadingBidan = true;

  @override
  void initState() {
    super.initState();
    _loadBidan();
  }

  Future<void> _loadBidan() async {
    try {
      final list = await _supabaseService.getBidan();
      setState(() {
        _bidanList = list;
        _isLoadingBidan = false;

        // Auto-select jika sudah ada bidan di data reservasi
        final existingBidanId = widget.data['bidan_id'];
        if (existingBidanId != null) {
          final index = _bidanList.indexWhere((b) => b['id'] == existingBidanId);
          if (index != -1) selectedBidan = index;
        }
      });
    } catch (e) {
      setState(() => _isLoadingBidan = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      String? bidanId;
      if (status == 'Dikonfirmasi' && selectedBidan != -1) {
        bidanId = _bidanList[selectedBidan]['id'];
      }

      await _supabaseService.updateStatusReservasi(
        widget.data['id'],
        status,
        statusPelayanan: status == 'Dikonfirmasi' ? 'Diproses' : null,
        bidanId: bidanId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservasi berhasil $status')),
        );
        Navigator.pop(context, true); // Beri tahu halaman sebelumnya untuk refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isLocked = data['bidan_id'] != null;

    return Scaffold(
      backgroundColor: const Color(0xFFEECAD0),

      appBar: AppBar(
        title: const Text("Detail Reservasi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),

      bottomNavigationBar: _bottomNav(context),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ================= PROFILE =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE99AA3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    data['nama_pasien'] ?? data['namaPasien'] ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 TAMPILKAN BIDAN
                  Text(
                    data['bidan_profiles']?['nama'] ?? data['bidan'] ?? "Belum dipilih",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (data['bidan_profiles']?['nama'] == null && data['bidan'] == null)
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _infoCard(Icons.calendar_today, "TANGGAL",
                _displayDate(data['tanggal'])),
            const SizedBox(height: 10),
            _infoCard(Icons.access_time, "WAKTU", data['jam'] ?? '-'),
            const SizedBox(height: 10),
            _infoCard(Icons.note, "LAYANAN", data['layanan'] ?? '-'),

            const SizedBox(height: 20),

            /// ================= PILIH BIDAN =================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pilih Bidan Untuk Pelayanan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            if (_isLoadingBidan)
              const Center(child: CircularProgressIndicator())
            else if (_bidanList.isEmpty)
              const Text("Bidan tidak tersedia", style: TextStyle(color: Colors.grey))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    _bidanList.length,
                    (index) {
                      final bidan = _bidanList[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _bidanItem(
                            "Bidan ${_getFirstName(bidan['nama'] ?? 'Bidan')}", index, isLocked),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 10),

            if (selectedBidan != -1 && !_isLoadingBidan)
              Text(
                "Dipilih: Bidan ${_getFirstName(_bidanList[selectedBidan]['nama'] ?? '')}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

            if (isLocked)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "Bidan sudah ditentukan",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 20),

            /// ================= BUTTON =================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLocked
                        ? null
                        : selectedBidan == -1
                            ? null
                            : () => _updateStatus('Dikonfirmasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("✔ Terima"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLocked
                        ? null
                        : () => _updateStatus('Ditolak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("✖ Tolak"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ================= BIDAN ITEM =================
  Widget _bidanItem(String name, int index, bool isLocked) {
    final isSelected = selectedBidan == index;

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              setState(() {
                selectedBidan = index;
              });
            },
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    isSelected ? Colors.green : Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),

              if (isSelected)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check,
                        size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              color: isLocked ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= INFO CARD =================
  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF5D8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  String _displayDate(String? iso) {
    if (iso == null || iso.toString().isEmpty) return "-";
    final date = DateTime.tryParse(iso.toString()) ?? DateTime.now();

    const bulan = [
      'JANUARI','FEBRUARI','MARET','APRIL','MEI','JUNI',
      'JULI','AGUSTUS','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER'
    ];

    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
        }
        if (index == 1) {
          Navigator.pushNamedAndRemoveUntil(context, '/admin_jadwal', (route) => false);
        }
        if (index == 2) {
          // Navigator.pushNamed(context, '/admin_chat_list'); // Jika sudah ada rutenya
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