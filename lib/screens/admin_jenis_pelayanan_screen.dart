import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_tambah_jenis_pelayanan_screen.dart';
import 'admin_edit_pelayanan_screen.dart';
import '../models/jenis_pelayanan.dart';
import 'admin_chat_list_screen.dart';

class AdminJenisPelayananScreen extends StatefulWidget {
  const AdminJenisPelayananScreen({super.key});
  @override
  State<AdminJenisPelayananScreen> createState() => _AdminJenisPelayananScreenState();
}

class _AdminJenisPelayananScreenState extends State<AdminJenisPelayananScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int selectedTab = 0;

  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text("Jenis Pelayanan", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getJenisPelayanan(),
        builder: (context, snapshot) {
          final allData = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          return Column(children: [
            // Tab bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [_tabItem("Layanan Klinik", 0), _tabItem("Home Care", 1)]),
            ),
            const SizedBox(height: 12),
            if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: _accent)))
            else Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: _filteredList(allData))),
            // Add button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTambahJenisPelayananScreen())).then((_) => setState(() {})); },
                icon: const Icon(Icons.add_rounded), label: const Text("Tambah Jenis Pemeriksaan", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              )),
            ),
          ]);
        },
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  List<Widget> _filteredList(List<Map<String, dynamic>> allData) {
    final isHomeCareTab = selectedTab == 1;
    final data = allData.where((e) => (e['is_home_care'] == true) == isHomeCareTab).toList();
    if (data.isEmpty) return [const Padding(padding: EdgeInsets.all(30), child: Center(child: Text("Belum ada data", style: TextStyle(color: _textSecondary))))];
    return data.map((json) {
      final hargaRaw = json['harga'];
      final hargaFormatted = (hargaRaw is int) ? "Rp $hargaRaw" : (hargaRaw?.toString() ?? "Rp 0");
      final layanan = JenisPelayanan(nama: json['nama'] ?? '-', deskripsi: json['deskripsi'] ?? '-', harga: hargaFormatted, kategori: json['kategori'] ?? '-');
      return _card(layanan, json['id']?.toString());
    }).toList();
  }

  Widget _card(JenisPelayanan layanan, String? id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(layanan.nama, style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 15))),
          Row(children: [
            GestureDetector(
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => AdminEditPelayananScreen(layanan: layanan, serviceId: id))).then((_) => setState(() {})); },
              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1565C0))),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () async { if (id != null) { try { await _supabaseService.deleteJenisPelayanan(id); setState(() {}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layanan berhasil dihapus'))); } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'))); } } },
              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFE53935))),
            ),
          ]),
        ]),
        const SizedBox(height: 8),
        Text(layanan.deskripsi, style: const TextStyle(fontSize: 12, color: _textSecondary)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(layanan.harga, style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 14)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
            child: Text(layanan.kategori, style: const TextStyle(fontSize: 10, color: _accent, fontWeight: FontWeight.w600))),
        ]),
      ]),
    );
  }

  Widget _tabItem(String title, int index) {
    final isActive = selectedTab == index;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isActive ? _accent : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.white : _textSecondary, fontSize: 13)),
      ),
    ));
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, type: BottomNavigationBarType.fixed, selectedItemColor: _accent, unselectedItemColor: const Color(0xFFB0BEC5),
      onTap: (index) {
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => AdminChatListScreen()));
        if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPasienScreen()));
        if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
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
