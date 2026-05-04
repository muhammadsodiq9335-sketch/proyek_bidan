import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_service.dart';
import '../mock_data.dart';
import 'pdf_viewer_screen.dart';

class AdminArtikelScreen extends StatefulWidget {
  const AdminArtikelScreen({super.key});

  @override
  State<AdminArtikelScreen> createState() => _AdminArtikelScreenState();
}

class _AdminArtikelScreenState extends State<AdminArtikelScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;

  Future<void> _pickPDF() async {
    try {
      setState(() => _isLoading = true);
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        String fileName = result.files.single.name;
        String filePath = result.files.single.path!;

        await _supabaseService.tambahArtikelPdf({
          'nama_file': fileName,
          'url_pdf': filePath, // In real app, upload to Supabase Storage first
          'tanggal_upload': DateTime.now().toIso8601String(),
        });

        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File berhasil ditambahkan ke database!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _deleteArtikel(String id, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: Text('Apakah Anda yakin ingin menghapus $fileName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await _supabaseService.deleteArtikelPdf(id);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Artikel berhasil dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edukasi / Artikel",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00897B)))
          : FutureBuilder<List<ArtikelPdf>>(
              future: _supabaseService.getArtikelPdf(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        ),
                        title: Text(
                          artikel.namaFile,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text("Diunggah: $dateString", style: const TextStyle(fontSize: 12)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteArtikel(artikel.id, artikel.namaFile),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                filePath: artikel.urlPdf,
                                fileName: artikel.namaFile,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickPDF,
        backgroundColor: const Color(0xFF00897B),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload PDF'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.picture_as_pdf_outlined, size: 80, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            "Belum ada artikel",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Text(
            "Klik tombol di bawah untuk mengunggah PDF",
            style: TextStyle(color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
