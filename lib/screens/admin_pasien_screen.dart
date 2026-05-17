import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_detail_pembayaran_screen.dart';

class AdminPasienScreen extends StatefulWidget {
  const AdminPasienScreen({super.key});
  @override
  State<AdminPasienScreen> createState() => _AdminPasienScreenState();
}

class _AdminPasienScreenState extends State<AdminPasienScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  // Data state
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;
  String? _errorMsg;

  // Filter state
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );
  bool _filterByDate = true; // true = filter by range by default
  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  // ── Design Tokens ──
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  static const List<String> _dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const List<String> _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatDateRangeStr() {
    if (_selectedDateRange == null) return 'Pilih Periode Tanggal';
    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end;
    
    final startStr = '${start.day} ${_monthNames[start.month - 1]} ${start.year}';
    final endStr = '${end.day} ${_monthNames[end.month - 1]} ${end.year}';
    
    if (start.day == end.day && start.month == end.month && start.year == end.year) {
      return startStr;
    }
    return '$startStr - $endStr';
  }

  // Ambil semua data atau filter by tanggal
  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      List<Map<String, dynamic>> data;
      if (_filterByDate && _selectedDateRange != null) {
        data = await _supabaseService.getReservasiByDateRange(_selectedDateRange!.start, _selectedDateRange!.end);
      } else {
        data = await _supabaseService.getReservasi();
      }
      if (mounted) setState(() { _allData = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  void _showAll() {
    setState(() {
      _filterByDate = false;
      _currentPage = 0;
    });
    _loadData();
  }

  // Filter by search (dari data yang sudah diload)
  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _allData;
    final q = _searchQuery.toLowerCase();
    return _allData.where((r) {
      final nama = (r['nama_pasien'] ?? r['namaPasien'] ?? '').toString().toLowerCase();
      return nama.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
            }
          },
        ),
        title: const Text("Riwayat Pembayaran Pasien", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          // Tombol refresh manual
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _accent),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 14),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildPaymentTable(),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  // ══════════════════════ SEARCH BAR ══════════════════════
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: _cardShadow),
      child: TextField(
        onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 0; }),
        decoration: InputDecoration(
          hintText: 'Cari pasien berdasarkan nama...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: _textSecondary, size: 20),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime initial) async {
    return await showDatePicker(
      context: context,
      initialDate: initial,
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
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _accent,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // ══════════════════════ DATE RANGE PICKER ══════════════════════
  Widget _buildDatePicker() {
    final start = _selectedDateRange?.start ?? DateTime.now();
    final end = _selectedDateRange?.end ?? DateTime.now();

    final startStr = '${start.day} ${_monthNames[start.month - 1]} ${start.year}';
    final endStr = '${end.day} ${_monthNames[end.month - 1]} ${end.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: _cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_rounded, size: 18, color: _accent),
              const SizedBox(width: 8),
              const Text(
                'Pilih Periode Tanggal',
                style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 13, fontFamily: 'Outfit'),
              ),
              const Spacer(),
              // Tombol Semua
              if (_filterByDate)
                GestureDetector(
                  onTap: _showAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Semua', style: TextStyle(fontSize: 11, color: _accent, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Tanggal Mulai
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await _pickDate(start);
                    if (picked != null) {
                      setState(() {
                        DateTime newStart = picked;
                        DateTime newEnd = _selectedDateRange?.end ?? picked;
                        if (newStart.isAfter(newEnd)) {
                          newEnd = newStart;
                        }
                        _selectedDateRange = DateTimeRange(start: newStart, end: newEnd);
                        _filterByDate = true;
                        _currentPage = 0;
                      });
                      _loadData();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _accent.withAlpha(40), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mulai Dari',
                          style: TextStyle(fontSize: 9, color: _textSecondary, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: _accent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _filterByDate ? startStr : '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _accent,
                                  fontSize: 12,
                                  fontFamily: 'Outfit',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('s/d', style: TextStyle(fontWeight: FontWeight.bold, color: _textSecondary, fontSize: 11, fontFamily: 'Outfit')),
              const SizedBox(width: 8),
              // Tanggal Selesai
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await _pickDate(end);
                    if (picked != null) {
                      setState(() {
                        DateTime newStart = _selectedDateRange?.start ?? picked;
                        DateTime newEnd = picked;
                        if (newEnd.isBefore(newStart)) {
                          newStart = newEnd;
                        }
                        _selectedDateRange = DateTimeRange(start: newStart, end: newEnd);
                        _filterByDate = true;
                        _currentPage = 0;
                      });
                      _loadData();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _accent.withAlpha(40), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sampai Dengan',
                          style: TextStyle(fontSize: 9, color: _textSecondary, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: _accent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _filterByDate ? endStr : '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _accent,
                                  fontSize: 12,
                                  fontFamily: 'Outfit',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════ PAYMENT TABLE ══════════════════════
  Widget _buildPaymentTable() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: _accent),
        ),
      );
    }

    if (_errorMsg != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: _cardShadow),
        child: Column(children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
          const SizedBox(height: 8),
          Text('Gagal memuat data: $_errorMsg', textAlign: TextAlign.center, style: const TextStyle(color: _textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ]),
      );
    }

    final filtered = _filtered;
    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _itemsPerPage).ceil();
    if (_currentPage >= totalPages) _currentPage = totalPages - 1;
    if (_currentPage < 0) _currentPage = 0;
    final pageItems = filtered.skip(_currentPage * _itemsPerPage).take(_itemsPerPage).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: _cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('RIWAYAT PEMBAYARAN PASIEN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textPrimary, letterSpacing: 0.3)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(6)),
                child: Text('${filtered.length} data', style: const TextStyle(fontSize: 10, color: _accent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('NAMA PASIEN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _textSecondary, letterSpacing: 0.3))),
                Expanded(flex: 2, child: Text('TGL LAHIR', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _textSecondary, letterSpacing: 0.3))),
                Expanded(flex: 3, child: Text('ALAMAT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _textSecondary, letterSpacing: 0.3))),
                Expanded(flex: 2, child: Text('PEMBAYARAN', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _textSecondary, letterSpacing: 0.3))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (pageItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(child: Column(children: [
                Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  _filterByDate
                    ? 'Tidak ada reservasi pada periode\n${_formatDateRangeStr()}'
                    : 'Belum ada data pembayaran',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textSecondary, fontSize: 13),
                ),
              ])),
            )
          else
            ...pageItems.map((r) => _tableRow(r)),
          const SizedBox(height: 10),
          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_currentPage + 1}/$totalPages', style: const TextStyle(fontSize: 12, color: _textSecondary)),
              Row(children: [
                if (_currentPage > 0)
                  GestureDetector(
                    onTap: () => setState(() => _currentPage--),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Sebelumnya', style: TextStyle(fontSize: 11, color: _accent, fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (_currentPage > 0 && _currentPage < totalPages - 1) const SizedBox(width: 6),
                if (_currentPage < totalPages - 1)
                  GestureDetector(
                    onTap: () => setState(() => _currentPage++),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Selanjutnya', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableRow(Map<String, dynamic> r) {
    final nama = r['nama_pasien'] ?? r['namaPasien'] ?? '-';
    final tanggalLahir = r['tgl_lahir'];
    final alamat = r['alamat'] ?? r['lokasi'] ?? '-';
    final isSelesai = r['status'] == 'Selesai' || r['status_pelayanan'] == 'Selesai & Pulang';
    final String statusPelayanan = r['status_pelayanan'] ?? 'Menunggu';
    final bool isServiceDone = statusPelayanan == 'Diproses' || statusPelayanan == 'Selesai & Pulang';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(nama.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textPrimary))),
          Expanded(flex: 2, child: Text(_formatDate(tanggalLahir), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: _textPrimary))),
          Expanded(flex: 3, child: Text(alamat.toString(), style: const TextStyle(fontSize: 11, color: _textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Center(child: GestureDetector(
            onTap: () {
              if (!isServiceDone) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pelayanan belum diselesaikan! Silakan selesaikan pemeriksaan (SOAP) di Ringkasan Harian terlebih dahulu."),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDetailPembayaranScreen(pasien: r))).then((_) => _loadData());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isSelesai 
                    ? const Color(0xFFE8F5E9) 
                    : (!isServiceDone ? Colors.grey.shade100 : const Color(0xFFFFF0F5)),
                borderRadius: BorderRadius.circular(6),
                border: isSelesai 
                    ? null 
                    : (!isServiceDone ? Border.all(color: Colors.grey.shade300, width: 0.5) : null),
              ),
              child: Text(
                isSelesai 
                    ? 'Selesai' 
                    : (!isServiceDone ? 'Belum\nPelayanan' : 'Detail\nPembayaran'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9, 
                  fontWeight: FontWeight.bold, 
                  color: isSelesai 
                      ? const Color(0xFF2E7D32) 
                      : (!isServiceDone ? Colors.grey : _accent),
                ),
              ),
            ),
          ))),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    final d = DateTime.tryParse(date.toString());
    if (d == null) return date.toString();
    return '${d.day} ${_monthNames[d.month - 1]}\n${d.year}';
  }

  // ══════════════════════ BOTTOM NAV ══════════════════════
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, type: BottomNavigationBarType.fixed,
      selectedItemColor: _accent, unselectedItemColor: const Color(0xFFB0BEC5),
      onTap: (index) {
        if (index == 3) return;
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
