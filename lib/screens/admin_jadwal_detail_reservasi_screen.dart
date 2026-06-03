import 'package:flutter/material.dart';
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

  bool _isChangingBidan = false;

  Future<void> _updateStatus(String status, {String? alasan}) async {
    try {
      String? bidanId;
      if (status == 'Dikonfirmasi') {
        if (selectedBidan != -1) {
          bidanId = _bidanList[selectedBidan]['id'];
        } else if (widget.data['bidan_id'] != null) {
          bidanId = widget.data['bidan_id'];
        }
      }

      await _supabaseService.updateStatusReservasi(
        widget.data['id'],
        status,
        statusPelayanan: status == 'Dikonfirmasi' ? 'Menunggu' : null,
        bidanId: bidanId,
        alasanDitolak: alasan,
      );

      // Kirim Notifikasi ke Pasien
      if (widget.data['user_id'] != null) {
        String title = '';
        String message = '';
        String icon = 'info';

        if (status == 'Dikonfirmasi') {
          title = 'Reservasi Diterima';
          message = 'Reservasi Anda untuk ${widget.data['layanan']} telah dikonfirmasi.';
          icon = 'check_circle';
        } else if (status == 'Ditolak') {
          title = 'Reservasi Ditolak';
          message = 'Maaf, reservasi Anda ditolak${alasan != null ? ': $alasan' : '.'}';
          icon = 'info';
        }

        await _supabaseService.tambahNotifikasi(
          userId: widget.data['user_id'],
          title: title,
          message: message,
          icon: icon,
          screen: 'riwayat',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reservasi berhasil $status'),
            backgroundColor: _accent,
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

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alasan Penolakan'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Masukkan alasan...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus('Ditolak', alasan: reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak Reservasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangeBidanDialog() {
    if (selectedBidan == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih bidan terlebih dahulu')),
      );
      return;
    }
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alasan Ganti Bidan'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Misal: Bidan berhalangan hadir...',
            labelText: 'Alasan (Opsional)',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _changeBidan(reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accent),
            child: const Text('Konfirmasi Ganti', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _changeBidan(String reason) async {
    try {
      final newBidan = _bidanList[selectedBidan];
      await _supabaseService.updateReservasi(widget.data['id'], {
        'bidan_id': newBidan['id'],
        'status': 'Bidan Diganti', // Membutuhkan konfirmasi pasien
      });

      // Notifikasi ganti bidan
      if (widget.data['user_id'] != null) {
        String msg = 'Bidan untuk reservasi Anda telah diganti menjadi ${newBidan['nama']}.';
        if (reason.isNotEmpty) {
          msg += '\nAlasan: $reason';
        }
        msg += '\n\nSilakan buka menu Riwayat untuk menyetujui atau membatalkan reservasi.';

        await _supabaseService.tambahNotifikasi(
          userId: widget.data['user_id'],
          title: 'Perubahan Bidan',
          message: msg,
          icon: 'people',
          screen: 'riwayat',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bidan berhasil diganti. Menunggu konfirmasi pasien.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengganti bidan: $e')),
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
      'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
      'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER'
    ];
    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final hasBidan = data['bidan_id'] != null;
    final bidanNama = data['bidan_profiles']?['nama'] ?? data['bidan'] ?? "Belum dipilih";
    final selectedBidanMap = selectedBidan != -1 && selectedBidan < _bidanList.length ? _bidanList[selectedBidan] : null;
    final selectedBidanFotoUrl = selectedBidanMap?['foto_url'];

    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        title: const Text("Detail Reservasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
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
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['nama_pasien'] ?? '-',
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
                      "Bidan: $bidanNama",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
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
            if (data['keluhan'] != null) ...[
              const SizedBox(height: 10),
              _keluhanCard(data['keluhan'].toString()),
            ],

            const SizedBox(height: 20),

            /// ================= PILIH / GANTI BIDAN =================
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isChangingBidan && data['status'] == 'Menunggu Persetujuan' ? "Pilih Bidan Baru" : "Bidan Pelayanan",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
                      ),
                      if (hasBidan && !_isChangingBidan && data['status'] == 'Menunggu Persetujuan')
                        TextButton.icon(
                          onPressed: () => setState(() => _isChangingBidan = true),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text("Ganti Bidan", style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if ((_isChangingBidan || !hasBidan) && data['status'] == 'Menunggu Persetujuan') ...[
                    if (_isLoadingBidan)
                      const Center(child: CircularProgressIndicator())
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            _bidanList.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: _bidanItem(
                                "Bidan ${_getFirstName(_bidanList[index]['nama'] ?? '')}", index, false),
                            ),
                          ),
                        ),
                      ),
                    if (selectedBidan != -1 && _isChangingBidan)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showChangeBidanDialog,
                            style: ElevatedButton.styleFrom(backgroundColor: _accent),
                            child: const Text("Konfirmasi Ganti Bidan", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                  ] else
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: selectedBidanFotoUrl != null && selectedBidanFotoUrl.toString().isNotEmpty
                            ? NetworkImage(selectedBidanFotoUrl.toString())
                            : null,
                        child: selectedBidanFotoUrl != null && selectedBidanFotoUrl.toString().isNotEmpty
                            ? null
                            : const Icon(Icons.person),
                      ),
                      title: Text(bidanNama, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(hasBidan ? "Dipilih oleh Pasien" : "Belum dipilih"),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= BUTTONS & STATUS =================
            if (data['status'] == 'Menunggu Persetujuan')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus('Dikonfirmasi'),
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      label: const Text("Terima", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showRejectDialog,
                      icon: const Icon(Icons.close_rounded, color: Colors.red),
                      label: const Text("Tolak", style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _statusCard(data['status'] ?? ''),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(String status) {
    Color cardColor;
    Color textColor;
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case 'Dikonfirmasi':
        cardColor = const Color(0xFFE8F5E9); // Light green
        textColor = const Color(0xFF2E7D32); // Deep green
        icon = Icons.check_circle_rounded;
        title = "Reservasi Dikonfirmasi";
        subtitle = "Reservasi ini telah disetujui dan dikonfirmasi.";
        break;
      case 'Selesai':
        cardColor = const Color(0xFFE0F2F1); // Light teal
        textColor = const Color(0xFF00695C); // Deep teal
        icon = Icons.task_alt_rounded;
        title = "Pelayanan Selesai";
        subtitle = "Pelayanan medis telah selesai dilaksanakan.";
        break;
      case 'Ditolak':
        cardColor = const Color(0xFFFFEBEE); // Light red
        textColor = const Color(0xFFC62828); // Deep red
        icon = Icons.cancel_rounded;
        title = "Reservasi Ditolak";
        subtitle = widget.data['alasan_ditolak'] != null && widget.data['alasan_ditolak'].toString().isNotEmpty
            ? "Alasan: ${widget.data['alasan_ditolak']}"
            : "Reservasi ini telah ditolak oleh admin.";
        break;
      case 'Dibatalkan':
        cardColor = const Color(0xFFFFEBEE); // Light red
        textColor = const Color(0xFFC62828); // Deep red
        icon = Icons.cancel_rounded;
        title = "Reservasi Dibatalkan";
        subtitle = "Reservasi ini telah dibatalkan oleh pasien.";
        break;
      case 'Bidan Diganti':
        cardColor = const Color(0xFFFFF3E0); // Light orange
        textColor = const Color(0xFFE65100); // Deep orange
        icon = Icons.swap_horiz_rounded;
        title = "Bidan Diganti";
        subtitle = "Menunggu persetujuan pasien untuk bidan baru.";
        break;
      default:
        cardColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.info_rounded;
        title = status;
        subtitle = "Status reservasi saat ini.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  backgroundImage: _bidanList[index]['foto_url'] != null && _bidanList[index]['foto_url'].toString().isNotEmpty
                      ? NetworkImage(_bidanList[index]['foto_url'].toString())
                      : null,
                  child: _bidanList[index]['foto_url'] != null && _bidanList[index]['foto_url'].toString().isNotEmpty
                      ? null
                      : Icon(Icons.person, color: isSelected ? _accent : _textSecondary),
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

  /// ================= KELUHAN CARD =================
  Widget _keluhanCard(String keluhan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow,
        border: Border.all(color: const Color(0xFFC5E1A5), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.health_and_safety_outlined,
                    color: Color(0xFF558B2F), size: 18),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KELUHAN AWAL PASIEN',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF78909C),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Dicatat saat mendaftar',
                    style: TextStyle(fontSize: 10, color: Color(0xFF558B2F)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              keluhan,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1B2E35),
                  height: 1.5),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: _textSecondary, letterSpacing: 1, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
              ],
            ),
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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}
