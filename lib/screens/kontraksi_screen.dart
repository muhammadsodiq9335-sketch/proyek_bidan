import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

class KontraksiScreen extends StatefulWidget {
  const KontraksiScreen({super.key});

  @override
  State<KontraksiScreen> createState() => _KontraksiScreenState();
}

// Model data satu kontraksi
class _KontraksiEntry {
  final DateTime waktuMulai;
  final int durasiDetik;
  final int? intervalDetik; // null jika ini kontraksi pertama

  _KontraksiEntry({
    required this.waktuMulai,
    required this.durasiDetik,
    this.intervalDetik,
  });
}

class _KontraksiScreenState extends State<KontraksiScreen>
    with TickerProviderStateMixin {
  // State timer
  bool _sedangKontraksi = false;
  DateTime? _waktuMulaiKontraksi;
  DateTime? _waktuSelesaiKontraksi;

  // Daftar riwayat kontraksi dalam sesi ini
  final List<_KontraksiEntry> _daftarKontraksi = [];

  // Timer untuk update UI setiap detik
  Timer? _timerUI;
  int _detikBerjalan = 0; // detik timer yang sedang berjalan

  // Animasi tombol
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timerUI?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // Mulai / Selesai kontraksi
  void _toggleKontraksi() async {
    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(duration: 150, amplitude: 128); // Getar singkat
    }
    
    if (!_sedangKontraksi) {
      // --- MULAI kontraksi ---
      setState(() {
        _sedangKontraksi = true;
        _waktuMulaiKontraksi = DateTime.now();
        _detikBerjalan = 0;
      });
      _timerUI = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _detikBerjalan++);
      });
    } else {
      // --- SELESAI kontraksi ---
      _timerUI?.cancel();
      final selesai = DateTime.now();
      final durasi =
          selesai.difference(_waktuMulaiKontraksi!).inSeconds;

      int? interval;
      if (_waktuSelesaiKontraksi != null) {
        interval =
            _waktuMulaiKontraksi!.difference(_waktuSelesaiKontraksi!).inSeconds;
      }

      setState(() {
        _daftarKontraksi.insert(
          0,
          _KontraksiEntry(
            waktuMulai: _waktuMulaiKontraksi!,
            durasiDetik: durasi,
            intervalDetik: interval,
          ),
        );
        _waktuSelesaiKontraksi = selesai;
        _sedangKontraksi = false;
        _detikBerjalan = 0;
      });
    }
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Semua?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Seluruh riwayat kontraksi dalam sesi ini akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _timerUI?.cancel();
              setState(() {
                _daftarKontraksi.clear();
                _sedangKontraksi = false;
                _waktuMulaiKontraksi = null;
                _waktuSelesaiKontraksi = null;
                _detikBerjalan = 0;
              });
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Hitung statistik ──
  int get _jumlah1JamTerakhir {
    final batas = DateTime.now().subtract(const Duration(hours: 1));
    return _daftarKontraksi
        .where((e) => e.waktuMulai.isAfter(batas))
        .length;
  }

  double get _rataRataDurasi {
    if (_daftarKontraksi.isEmpty) return 0;
    final total =
        _daftarKontraksi.fold<int>(0, (sum, e) => sum + e.durasiDetik);
    return total / _daftarKontraksi.length;
  }

  double get _rataRataInterval {
    final punya = _daftarKontraksi.where((e) => e.intervalDetik != null).toList();
    if (punya.isEmpty) return 0;
    final total = punya.fold<int>(0, (sum, e) => sum + e.intervalDetik!);
    return total / punya.length;
  }

  // Format detik → "M:SS"
  String _formatDetik(int detik) {
    final m = detik ~/ 60;
    final s = detik % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _formatDouble(double detik) => _formatDetik(detik.round());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1B2E35)),
        title: const Text(
          'Penghitung Kontraksi',
          style: TextStyle(
            color: Color(0xFF1B2E35),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildStatistikBar(),
          Expanded(
            child: _daftarKontraksi.isEmpty && !_sedangKontraksi
                ? _buildEmptyState()
                : _buildListKontraksi(),
          ),
          _buildTombolKontraksi(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Statistik Bar ──
  Widget _buildStatistikBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          _buildStat(
            'RATA-RATA\nDURASI',
            _daftarKontraksi.isEmpty ? '-' : _formatDouble(_rataRataDurasi),
          ),
          _buildDivider(),
          _buildStat(
            '1 JAM\nTERAKHIR',
            _jumlah1JamTerakhir.toString(),
          ),
          _buildDivider(),
          _buildStat(
            'RATA-RATA\nFREKUENSI',
            _rataRataInterval == 0 ? '-' : _formatDouble(_rataRataInterval),
          ),
          _buildDivider(),
          GestureDetector(
            onTap: _reset,
            child: Column(
              children: const [
                Icon(Icons.refresh_rounded, color: Color(0xFF00897B), size: 22),
                SizedBox(height: 4),
                Text(
                  'RESET',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              color: Colors.black45,
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: const Color(0xFFEEEEEE),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // ── List Kontraksi ──
  Widget _buildListKontraksi() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Header kolom
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'DURASI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                    letterSpacing: 1,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_daftarKontraksi.isEmpty) return;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Hapus Riwayat?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      content: const Text(
                          'Semua riwayat kontraksi sesi ini akan dihapus.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal',
                              style: TextStyle(color: Colors.black54)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() => _daftarKontraksi.clear());
                          },
                          child: const Text('Hapus',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline, color: Colors.red, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'HAPUS RIWAYAT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Text(
                  'FREKUENSI',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E35),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Baris "sedang berjalan" jika kontraksi aktif
        if (_sedangKontraksi) _buildBarisBerjalan(),

        // Daftar kontraksi selesai
        ..._daftarKontraksi.asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final nomorUrut = _daftarKontraksi.length - index;
          final isAktif = index < 2; // 2 kontraksi terakhir dianggap "aktif"
          return _buildBarisKontraksi(e, nomorUrut, isAktif);
        }),
        const SizedBox(height: 100), // padding bawah untuk tombol
      ],
    );
  }

  Widget _buildBarisBerjalan() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF00897B), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDetik(_detikBerjalan),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00897B),
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(_waktuMulaiKontraksi!),
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF00897B),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              (_daftarKontraksi.length + 1).toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: SizedBox()), // kosong karena belum selesai
        ],
      ),
    );
  }

  Widget _buildBarisKontraksi(
      _KontraksiEntry e, int nomorUrut, bool isAktif) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDetik(e.durasiDetik),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(e.waktuMulai),
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isAktif ? const Color(0xFF00897B) : const Color(0xFFB2DFDB),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              nomorUrut.toString(),
              style: TextStyle(
                color: isAktif ? Colors.white : const Color(0xFF00695C),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                e.intervalDetik != null ? _formatDetik(e.intervalDetik!) : '-',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, size: 60, color: Colors.pink.shade100),
          const SizedBox(height: 16),
          const Text(
            'Belum ada kontraksi tercatat',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black45),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tekan tombol MULAI saat kontraksi dimulai,\nlalu tekan lagi saat selesai.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  // ── Tombol Besar Kontraksi ──
  Widget _buildTombolKontraksi() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: _toggleKontraksi,
        child: ScaleTransition(
          scale: _sedangKontraksi ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _sedangKontraksi
                  ? const Color(0xFFFF5252)
                  : const Color(0xFF00897B),
              boxShadow: [
                BoxShadow(
                  color: (_sedangKontraksi
                          ? const Color(0xFFFF5252)
                          : const Color(0xFF00897B))
                      .withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'KONTRAKSI',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _sedangKontraksi ? 'SELESAI' : 'MULAI',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
