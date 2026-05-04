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
    _loadBidan();
  }

  Future<void> _loadBidan() async {
    try {
      final list = await _supabaseService.getBidan();
      setState(() {
        _bidanList = list;
        _isLoadingBidan = false;
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
          SnackBar(
            content: Text('Reservasi berhasil $status'),
            backgroundColor: _accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status: $e')),
        );
      }
    }
  }

  String _formatJam(String? jam) {
    if (jam == null || jam.isEmpty || jam == '-') return '-';
    final parts = jam.split(':');
    if (parts.length >= 2) return "${parts[0]}:${parts[1]}";
    return jam;
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

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isLocked = data['bidan_id'] != null;

    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        title: const Text("Detail Reservasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _textPrimary,
        centerTitle: true,
      ),
      bottomNavigationBar: _bottomNav(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= PROFILE =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['nama_pasien'] ?? data['namaPasien'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data['bidan_profiles']?['nama'] ?? data['bidan'] ?? "Belum dipilih",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: (data['bidan_profiles']?['nama'] == null && data['bidan'] == null)
                            ? Colors.white70
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _infoCard(Icons.calendar_today_rounded, "TANGGAL", _displayDate(data['tanggal'])),
            const SizedBox(height: 10),
            _infoCard(Icons.access_time_rounded, "WAKTU", _formatJam(data['jam'])),
            const SizedBox(height: 10),
            _infoCard(Icons.medical_services_outlined, "LAYANAN", data['layanan'] ?? '-'),

            const SizedBox(height: 20),

            /// ================= PILIH BIDAN =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardRadius),
                boxShadow: _cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Bidan Untuk Pelayanan",
                    style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
                  ),
                  const SizedBox(height: 14),
                  if (_isLoadingBidan)
                    const Center(child: CircularProgressIndicator(color: _accent))
                  else if (_bidanList.isEmpty)
                    const Text("Bidan tidak tersedia", style: TextStyle(color: _textSecondary))
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          _bidanList.length,
                          (index) {
                            final bidan = _bidanList[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: _bidanItem(
                                "Bidan ${_getFirstName(bidan['nama'] ?? 'Bidan')}", index, isLocked),
                            );
                          },
                        ),
                      ),
                    ),
                  if (selectedBidan != -1 && !_isLoadingBidan) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _accentLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Dipilih: Bidan ${_getFirstName(_bidanList[selectedBidan]['nama'] ?? '')}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _accent),
                      ),
                    ),
                  ],
                  if (isLocked)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Bidan sudah ditentukan",
                        style: TextStyle(fontSize: 11, color: _textSecondary),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= BUTTON =================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLocked
                        ? null
                        : selectedBidan == -1
                            ? null
                            : () => _updateStatus('Dikonfirmasi'),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text("Terima", style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLocked ? null : () => _updateStatus('Ditolak'),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text("Tolak", style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE53935),
                      side: BorderSide(color: isLocked ? Colors.grey.shade300 : const Color(0xFFE53935)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
      onTap: isLocked ? null : () => setState(() => selectedBidan = index),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _accent : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: isSelected ? _accentLight : _bgInner,
                  child: Icon(Icons.person, color: isSelected ? _accent : _textSecondary),
                ),
              ),
              if (isSelected)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isLocked ? _textSecondary : _textPrimary,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accent, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: _textSecondary, letterSpacing: 1, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFC2185B),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
        }
        if (index == 1) {
          Navigator.pushNamedAndRemoveUntil(context, '/admin_jadwal', (route) => false);
        }
        if (index == 2) {
          // Navigator.pushNamed(context, '/admin_chat_list');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}