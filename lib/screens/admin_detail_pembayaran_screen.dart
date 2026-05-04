import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_jadwal_screen.dart';

class AdminDetailPembayaranScreen extends StatefulWidget {
  final Map<String, dynamic> pasien;
  const AdminDetailPembayaranScreen({super.key, required this.pasien});

  @override
  State<AdminDetailPembayaranScreen> createState() => _AdminDetailPembayaranScreenState();
}

class _AdminDetailPembayaranScreenState extends State<AdminDetailPembayaranScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  bool _isFetchingServices = false;
  int subtotal = 85000;
  List<Map<String, dynamic>> _availableServices = [];
  final List<Map<String, dynamic>> _selectedAdditionalServices = [];

  // ── Design Tokens ──
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _bgInner = Color(0xFFFFF0F5);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _accentLight = Color(0xFFF8E1E9);
  static const _cardRadius = 16.0;
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  bool get _isAlreadyPaid =>
      widget.pasien['status'] == 'Selesai' ||
      widget.pasien['status_pelayanan'] == 'Selesai & Pulang';

  int get tambahan => _selectedAdditionalServices.fold(0, (sum, item) {
    String priceStr = item['harga']?.toString() ?? "0";
    priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return sum + (int.tryParse(priceStr) ?? 0);
  });

  int get total => subtotal + tambahan;

  @override
  void initState() {
    super.initState();
    String priceStr = (widget.pasien['harga'] ?? "85000").toString();
    priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    subtotal = int.tryParse(priceStr) ?? 85000;
    _fetchAvailableServices();
  }

  Future<void> _fetchAvailableServices() async {
    setState(() => _isFetchingServices = true);
    try {
      final services = await _supabaseService.getJenisPelayanan();
      setState(() => _availableServices = services);
    } catch (e) {
      debugPrint("Error fetching services: $e");
    } finally {
      if (mounted) setState(() => _isFetchingServices = false);
    }
  }

  void _toggleService(Map<String, dynamic> service) {
    if (_isAlreadyPaid) return; // prevent changes if already paid
    setState(() {
      final index = _selectedAdditionalServices.indexWhere((s) => s['id'] == service['id']);
      if (index != -1) { _selectedAdditionalServices.removeAt(index); } else { _selectedAdditionalServices.add(service); }
    });
  }

  Future<void> _selesaikanPembayaran() async {
    setState(() => _isLoading = true);
    try {
      if (widget.pasien['id'] != null) {
        await _supabaseService.updateReservasi(widget.pasien['id'].toString(), {'status': 'Selesai', 'status_pelayanan': 'Selesai & Pulang'});
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Pembayaran berhasil dikonfirmasi"), backgroundColor: _accent, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(int value) {
    final str = value.toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) result.write('.');
    }
    return "Rp ${result.toString().split('').reversed.join()}";
  }

  @override
  Widget build(BuildContext context) {
    final pasien = widget.pasien;
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        title: const Text("Detail Pembayaran", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // ── INFO PASIEN ──
          _cardContainer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('INFORMASI PASIEN', style: TextStyle(fontSize: 10, color: _textSecondary, letterSpacing: 0.8, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(pasien['nama_pasien'] ?? pasien['namaPasien'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _textPrimary)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _bgInner, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                const Text("Layanan yang dibayar pasien :", style: TextStyle(fontSize: 10, color: _textSecondary)),
                const SizedBox(height: 4),
                Text(pasien['layanan'] ?? '-', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 14)),
                const SizedBox(height: 2),
                Text(_formatCurrency(subtotal), style: const TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 14)),
              ]),
            ),
          ])),

          const SizedBox(height: 14),

          // ── LAYANAN TAMBAHAN ──
          _cardContainer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Row(children: [
                Icon(Icons.add_circle_outline_rounded, size: 18, color: _accent),
                SizedBox(width: 8),
                Text("Layanan Tambahan", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
              ]),
              if (!_isAlreadyPaid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _accentLight, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Tambah\nLayanan', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: _accent, fontWeight: FontWeight.bold)),
                ),
            ]),
            const SizedBox(height: 4),
            Text(_isAlreadyPaid ? "Pembayaran sudah selesai" : "Pilih layanan tambahan jika diperlukan", style: const TextStyle(fontSize: 11, color: _textSecondary)),
            const SizedBox(height: 14),
            if (_isFetchingServices)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: _accent)))
            else if (_availableServices.isEmpty)
              const Text("Tidak ada layanan tambahan tersedia", style: TextStyle(fontSize: 12, color: _textSecondary))
            else
              ..._availableServices.map((service) {
                final isSelected = _selectedAdditionalServices.any((s) => s['id'] == service['id']);
                return Padding(padding: const EdgeInsets.only(bottom: 10), child: _serviceItem(
                  title: service['nama'] ?? '-',
                  durasi: service['deskripsi'] ?? service['durasi'] ?? '-',
                  harga: int.tryParse(service['harga']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0,
                  isSelected: isSelected,
                  onTap: () => _toggleService(service),
                ));
              }),
          ])),

          const SizedBox(height: 14),

          // ── RINGKASAN TAGIHAN ──
          _cardContainer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.receipt_long_rounded, size: 18, color: _accent),
              SizedBox(width: 8),
              Text("Ringkasan Tagihan", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
            ]),
            const SizedBox(height: 14),
            _rowHarga("Subtotal Reservasi Awal", subtotal),
            if (_selectedAdditionalServices.isNotEmpty) ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
              const Text("Total Layanan Tambahan:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary)),
              const SizedBox(height: 4),
              ..._selectedAdditionalServices.map((service) {
                int price = int.tryParse(service['harga']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
                return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: _rowHarga(service['nama'] ?? '-', price, isSmall: true));
              }),
            ],
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Total Tagihan", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 14)),
              Text(_formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 18)),
            ]),
          ])),

          const SizedBox(height: 20),

          // ── BUTTON ──
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _isAlreadyPaid ? null : (_isLoading ? null : _selesaikanPembayaran),
            icon: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Icon(_isAlreadyPaid ? Icons.check_circle_rounded : Icons.payment_rounded, size: 20),
            label: Text(
              _isAlreadyPaid ? "Pembayaran Selesai Dilakukan" : "Pembayaran Selesai",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAlreadyPaid ? const Color(0xFF4CAF50) : _accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF81C784),
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )),
          const SizedBox(height: 10),
        ]),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(_cardRadius), boxShadow: _cardShadow), child: child);
  }

  Widget _serviceItem({required String title, required String durasi, required int harga, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isSelected ? _accentLight : _bgInner, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? _accent : Colors.transparent, width: 1.5)),
      child: Row(children: [
        Container(width: 24, height: 24, decoration: BoxDecoration(color: isSelected ? _accent : Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: isSelected ? _accent : Colors.grey.shade300, width: 2)),
          child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? _accent : _textPrimary)),
          Text(durasi, style: const TextStyle(fontSize: 11, color: _textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Text(_formatCurrency(harga), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 12, color: isSelected ? _accent : _textPrimary)),
      ]),
    ));
  }

  Widget _rowHarga(String title, int value, {bool isSmall = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(fontSize: isSmall ? 12 : 13, color: isSmall ? _textSecondary : _textPrimary)),
      Text(_formatCurrency(value), style: TextStyle(fontSize: isSmall ? 12 : 13, fontWeight: isSmall ? FontWeight.normal : FontWeight.w600, color: isSmall ? _textSecondary : _textPrimary)),
    ]);
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, type: BottomNavigationBarType.fixed, selectedItemColor: _accent, unselectedItemColor: const Color(0xFFB0BEC5),
      onTap: (index) {
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
        if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPasienScreen()));
        if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
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