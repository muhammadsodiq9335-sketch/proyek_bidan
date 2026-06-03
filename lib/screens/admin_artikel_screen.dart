import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../models/artikel_pdf.dart';

class AdminArtikelScreen extends StatefulWidget {
  const AdminArtikelScreen({super.key});
  @override
  State<AdminArtikelScreen> createState() => _AdminArtikelScreenState();
}

class _AdminArtikelScreenState extends State<AdminArtikelScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;

  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  Future<void> _addLink() async {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    bool isFetching = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Link Artikel', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText: 'Masukkan Link Kemenkes',
                  labelText: 'Link URL',
                  suffixIcon: IconButton(
                    icon: isFetching 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync_rounded),
                    onPressed: () async {
                      final url = urlController.text.trim();
                      if (url.isEmpty) return;
                      setDialogState(() => isFetching = true);
                      try {
                        final response = await http.get(Uri.parse(url));
                        if (response.statusCode == 200) {
                          final match = RegExp(r'<title>(.*?)<\/title>').firstMatch(response.body);
                          if (match != null) {
                            titleController.text = match.group(1) ?? '';
                          }
                        }
                      } catch (e) {
                        print("Error fetch title: $e");
                      }
                      setDialogState(() => isFetching = false);
                    },
                  ),
                ),
                onChanged: (val) {
                  // Optional: auto fetch
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Judul akan muncul otomatis',
                  labelText: 'Judul Artikel',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                final title = titleController.text.trim();
                if (url.isEmpty || title.isEmpty) return;
                
                setState(() => _isLoading = true);
                Navigator.pop(context);
                
                try {
                  await _supabaseService.tambahArtikelPdf({
                    'nama_file': title,
                    'url_pdf': url,
                    'tanggal_upload': DateTime.now().toIso8601String()
                  });
                  setState(() {});
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteArtikel(String id, String fileName) {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Hapus Artikel', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text('Hapus "$fileName"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: _textSecondary))),
        ElevatedButton(onPressed: () async {
          await _supabaseService.deleteArtikelPdf(id);
          if (mounted) { Navigator.pop(context); setState(() {}); }
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Hapus')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text("Edukasi / Artikel", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: _accent))
        : FutureBuilder<List<ArtikelPdf>>(
            future: _supabaseService.getArtikelPdf(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: _accent));
              final list = snapshot.data ?? [];
              if (list.isEmpty) return _buildEmptyState();
              return ListView.builder(
                padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final artikel = list[index];
                  final dateString = "${artikel.tanggalUpload.day}/${artikel.tanggalUpload.month}/${artikel.tanggalUpload.year}";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.language_rounded, color: Color(0xFF00897B))),
                      title: Text(artikel.namaFile, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text("Ditambahkan: $dateString", style: const TextStyle(fontSize: 12, color: _textSecondary))),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935)), onPressed: () => _deleteArtikel(artikel.id, artikel.namaFile)),
                      onTap: () async {
                        final url = Uri.parse(artikel.urlPdf);
                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka link")));
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLink, backgroundColor: _accent, foregroundColor: Colors.white, elevation: 4,
        icon: const Icon(Icons.add_link_rounded), label: const Text('Tambah Link', style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.language_rounded, size: 64, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text("Belum ada artikel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
      const SizedBox(height: 8),
      const Text("Klik tombol di bawah untuk menambah link Kemenkes", style: TextStyle(color: _textSecondary, fontSize: 13)),
    ]));
  }
}
