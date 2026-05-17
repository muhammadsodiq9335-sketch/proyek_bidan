import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_service.dart';
import '../models/artikel_pdf.dart';
import 'pdf_viewer_screen.dart';

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

  Future<void> _pickPDF() async {
    try {
      setState(() => _isLoading = true);
      FilePickerResult? result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null && result.files.single.path != null) {
        String fileName = result.files.single.name;
        String filePath = result.files.single.path!;
        await _supabaseService.tambahArtikelPdf({'nama_file': fileName, 'url_pdf': filePath, 'tanggal_upload': DateTime.now().toIso8601String()});
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('File berhasil ditambahkan!'), backgroundColor: _accent, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memilih file: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                      leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFE53935))),
                      title: Text(artikel.namaFile, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text("Diunggah: $dateString", style: const TextStyle(fontSize: 12, color: _textSecondary))),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935)), onPressed: () => _deleteArtikel(artikel.id, artikel.namaFile)),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewerScreen(filePath: artikel.urlPdf, fileName: artikel.namaFile))),
                    ),
                  );
                },
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickPDF, backgroundColor: _accent, foregroundColor: Colors.white, elevation: 4,
        icon: const Icon(Icons.upload_file_rounded), label: const Text('Upload PDF', style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.picture_as_pdf_outlined, size: 64, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text("Belum ada artikel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
      const SizedBox(height: 8),
      const Text("Klik tombol di bawah untuk mengunggah PDF", style: TextStyle(color: _textSecondary, fontSize: 13)),
    ]));
  }
}
