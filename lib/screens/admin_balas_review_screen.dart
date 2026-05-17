import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AdminBalasReviewScreen extends StatefulWidget {
  final Map<String, dynamic> review;

  const AdminBalasReviewScreen({super.key, required this.review});

  @override
  State<AdminBalasReviewScreen> createState() => _AdminBalasReviewScreenState();
}

class _AdminBalasReviewScreenState extends State<AdminBalasReviewScreen> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;

  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _kirimBalasan() async {
    if (_controller.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      if (widget.review['id'] != null) {
        await _supabaseService.updateAdminReply(widget.review['id'].toString(), _controller.text);
        
        // Kirim Notifikasi ke Pasien
        if (widget.review['user_id'] != null) {
          await _supabaseService.tambahNotifikasi(
            userId: widget.review['user_id'].toString(),
            title: 'Ulasan Bunda Dibalas! 💌',
            message: 'Bidan telah membalas ulasan Bunda. Terima kasih atas masukannya!',
            screen: 'riwayat',
          );
        }

        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengirim balasan: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Balas Review', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        foregroundColor: _textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFFFF0F5),
                        child: Text(
                          ((widget.review['nama_pasien'] ?? widget.review['name'] ?? '-')[0]).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: _accent),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(widget.review['nama_pasien'] ?? widget.review['name'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.review['content'] ?? widget.review['review_text'] ?? '-', style: const TextStyle(color: _textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Tulis balasan...', hintStyle: TextStyle(color: _textSecondary), border: InputBorder.none),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _kirimBalasan,
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 18),
                label: const Text('Kirim Balasan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
