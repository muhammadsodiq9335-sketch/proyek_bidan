import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_tambah_bidan_screen.dart';

class AdminCekProfilBidanScreen extends StatefulWidget {
  const AdminCekProfilBidanScreen({super.key});

  @override
  State<AdminCekProfilBidanScreen> createState() =>
      _AdminCekProfilBidanScreenState();
}

class _AdminCekProfilBidanScreenState
    extends State<AdminCekProfilBidanScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  // ── Design Tokens ──
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profil Bidan",
          style: TextStyle(
              color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getBidan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _accent));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined,
                      size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text("Belum ada data bidan",
                      style: TextStyle(color: _textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) => _bidanCard(list[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AdminTambahBidanScreen()),
          ).then((_) => setState(() {}));
        },
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('Tambah Bidan',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _bidanCard(Map<String, dynamic> bidan) {
    final nama = bidan['nama'] ?? '-';
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFFFF0F5),
          backgroundImage: bidan['foto_url'] != null && bidan['foto_url'].toString().isNotEmpty
              ? NetworkImage(bidan['foto_url'].toString())
              : null,
          child: bidan['foto_url'] == null || bidan['foto_url'].toString().isEmpty
              ? Text(initial,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: _accent, fontSize: 16))
              : null,
        ),
        title: Text(nama,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: _textPrimary)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            bidan['str'] ?? bidan['nip'] ?? '-',
            style: const TextStyle(fontSize: 12, color: _textSecondary),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconBtn(Icons.edit_outlined, const Color(0xFF1565C0), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminTambahBidanScreen(
                    isEdit: true,
                    data: bidan.map((k, v) => MapEntry(k, v?.toString() ?? '')),
                  ),
                ),
              ).then((_) => setState(() {}));
            }),
            const SizedBox(width: 4),
            _iconBtn(Icons.delete_outline_rounded, const Color(0xFFE53935),
                () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Hapus Bidan?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Text('Apakah Anda yakin ingin menghapus "$nama"?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal',
                            style: TextStyle(color: _textSecondary))),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
              if (confirm == true && bidan['id'] != null) {
                await _supabaseService.deleteBidan(bidan['id'].toString());
                setState(() {});
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}