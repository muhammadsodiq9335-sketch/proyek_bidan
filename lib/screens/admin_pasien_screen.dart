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
  DateTime _selectedDate = DateTime.now();
  bool _filterByDate = false; // false = tampilkan semua
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

  // Ambil semua data atau filter by tanggal
  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      List<Map<String, dynamic>> data;
      if (_filterByDate) {
        data = await _supabaseService.getReservasiByDate(_selectedDate);
      } else {
        data = await _supabaseService.getReservasi();
      }
      if (mounted) setState(() { _allData = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filterByDate = true;
      _currentPage = 0;
    });
    _loadData();
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context)),
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

  // ══════════════════════ DATE PICKER ══════════════════════
  Widget _buildDatePicker() {
    final now = DateTime.now();
    // 7 hari: hari ini dan 6 hari ke depan (bisa scroll kiri = scroll semua)
    final dates = List.generate(7, (i) => now.add(Duration(days: i - 3)));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: _cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: _accent),
              const SizedBox(width: 6),
              const Text('Cek Tanggal', style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 13)),
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
              const SizedBox(width: 6),
              // Tombol buka calendar
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _accent)),
                      child: child!,
                    ),
                  );
                  if (picked != null) _onDateSelected(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.edit_calendar_rounded, size: 16, color: _accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Status filter aktif
          if (_filterByDate)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_alt_rounded, size: 13, color: _accent),
                    const SizedBox(width: 4),
                    Text(
                      'Menampilkan reservasi: ${_selectedDate.day} ${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
                      style: const TextStyle(fontSize: 11, color: _accent, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          // Horizontal date scroll
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, i) {
                final d = dates[i];
                final isSelected = _filterByDate &&
                    d.day == _selectedDate.day &&
                    d.month == _selectedDate.month &&
                    d.year == _selectedDate.year;
                final isToday = d.day == now.day && d.month == now.month && d.year == now.year;
                final dayName = _dayNames[d.weekday - 1];
                return GestureDetector(
                  onTap: () => _onDateSelected(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52, margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _accent : (isToday ? const Color(0xFFFCE4EC) : const Color(0xFFFFF0F5)),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? null : Border.all(color: isToday ? _accent.withAlpha(80) : Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dayName, style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white70 : (isToday ? _accent : _textSecondary),
                        )),
                        const SizedBox(height: 2),
                        Text('${d.day}', style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isToday ? _accent : _textPrimary),
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
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
                    ? 'Tidak ada reservasi pada ${_selectedDate.day} ${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}'
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDetailPembayaranScreen(pasien: r))).then((_) => _loadData());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isSelesai ? const Color(0xFFE8F5E9) : const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isSelesai ? 'Selesai' : 'Detail\nPembayaran',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelesai ? const Color(0xFF2E7D32) : _accent),
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
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
        if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
        if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat Bidan"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}