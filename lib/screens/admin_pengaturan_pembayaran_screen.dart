import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_service.dart';

class AdminPengaturanPembayaranScreen extends StatefulWidget {
  const AdminPengaturanPembayaranScreen({super.key});

  @override
  State<AdminPengaturanPembayaranScreen> createState() => _AdminPengaturanPembayaranScreenState();
}

class _AdminPengaturanPembayaranScreenState extends State<AdminPengaturanPembayaranScreen> {
  // ── Design Tokens ──
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  final _supabaseService = SupabaseService();
  
  // Controllers
  final bankNameC = TextEditingController();
  final rekNumberC = TextEditingController();
  final rekNameC = TextEditingController();
  final qrisNmidC = TextEditingController();
  final qrisNameC = TextEditingController();
  final qrisCodeC = TextEditingController();

  String? _fotoUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentSettings();
  }

  Future<void> _loadPaymentSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _supabaseService.getPaymentSettings();
      setState(() {
        bankNameC.text = settings['bank_name'] ?? 'BCA Syariah';
        rekNumberC.text = settings['rek_number'] ?? '0631999999';
        rekNameC.text = settings['rek_name'] ?? 'A.n ANNISA';
        qrisNmidC.text = settings['qris_nmid'] ?? 'ID1026496531744';
        qrisNameC.text = settings['qris_name'] ?? 'TAMAN IBU BIDAN ANNISA - HOME SERVICE';
        qrisCodeC.text = settings['qris_code'] ?? 'A01';
        _fotoUrl = settings['qris_url'] != '' ? settings['qris_url'] : null;
      });
    } catch (e) {
      debugPrint("Error loading settings: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final bytes = await image.readAsBytes();
        final fileName = 'qris_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        final url = await _supabaseService.uploadQrisImage(fileBytes: bytes, fileName: fileName);
        
        if (url != null) {
          setState(() => _fotoUrl = url);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Gambar QRIS berhasil diupload!"), backgroundColor: Colors.green),
            );
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal upload QRIS: $e")));
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (bankNameC.text.isEmpty || rekNumberC.text.isEmpty || rekNameC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data Bank (Nama Bank, No. Rekening, Atas Nama) wajib diisi"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'bank_name': bankNameC.text,
        'rek_number': rekNumberC.text,
        'rek_name': rekNameC.text,
        'qris_nmid': qrisNmidC.text,
        'qris_name': qrisNameC.text,
        'qris_code': qrisCodeC.text,
        'qris_url': _fotoUrl ?? '',
      };

      await _supabaseService.updatePaymentSettings(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengaturan QRIS & Bank berhasil disimpan!"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan pengaturan: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Pengaturan QRIS & Bank",
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header section
                        Row(
                          children: const [
                            Icon(Icons.account_balance_rounded, color: _accent, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Informasi Rekening Bank",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textPrimary),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        
                        _input("Nama Bank", "Contoh: BCA Syariah, Mandiri, dll.", bankNameC, Icons.account_balance_outlined),
                        _input("Nomor Rekening", "Masukkan nomor rekening bank", rekNumberC, Icons.credit_card_outlined),
                        _input("Nama Pemilik Rekening (A.n)", "Contoh: A.n ANNISA", rekNameC, Icons.person_outline_rounded),
                        
                        const SizedBox(height: 20),
                        
                        Row(
                          children: const [
                            Icon(Icons.qr_code_2_rounded, color: _accent, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Informasi QRIS",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textPrimary),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        
                        _input("Nama QRIS (Merchant)", "Contoh: TAMAN IBU BIDAN ANNISA", qrisNameC, Icons.storefront_outlined),
                        _input("NMID QRIS", "Contoh: ID1026496531744", qrisNmidC, Icons.qr_code_scanner_outlined),
                        _input("Kode QRIS", "Contoh: A01, dll.", qrisCodeC, Icons.code_rounded),
                        
                        const SizedBox(height: 14),
                        const Text(
                          "Gambar Code QRIS",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary),
                        ),
                        const SizedBox(height: 8),
                        
                        // Gambar QRIS
                        Center(
                          child: GestureDetector(
                            onTap: _isUploading ? null : _pickImage,
                            child: Container(
                              width: double.infinity,
                              height: 260,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _accent.withOpacity(0.2), width: 1.5),
                              ),
                              child: _fotoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            _fotoUrl!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Text("Gagal memuat gambar QRIS dari internet", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                              );
                                            },
                                          ),
                                          Positioned(
                                            bottom: 12,
                                            right: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _accent,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(Icons.edit, color: Colors.white, size: 12),
                                                  SizedBox(width: 4),
                                                  Text("Ubah QRIS", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _isUploading
                                            ? const CircularProgressIndicator(color: _accent)
                                            : const Icon(Icons.add_photo_alternate_outlined, size: 48, color: _accent),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Upload Kode Gambar QRIS",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Disarankan gambar berformat JPG/PNG",
                                          style: TextStyle(fontSize: 10, color: _textSecondary),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _textSecondary,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Batal"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isSaving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _input(String label, String hint, TextEditingController c, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            style: const TextStyle(fontSize: 14, color: _textPrimary, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(icon, size: 18, color: _accent),
              filled: true,
              fillColor: const Color(0xFFFFF0F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _accent, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
