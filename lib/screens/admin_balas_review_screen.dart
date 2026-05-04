import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AdminBalasReviewScreen extends StatefulWidget {
  final Map<String, dynamic> review;

  const AdminBalasReviewScreen({super.key, required this.review});

  @override
  State<AdminBalasReviewScreen> createState() =>
      _AdminBalasReviewScreenState();
}

class _AdminBalasReviewScreenState
    extends State<AdminBalasReviewScreen> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;

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
        await _supabaseService.balasReview(
          widget.review['id'].toString(),
          _controller.text,
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim balasan: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0D8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F0D8),
        elevation: 0,
        title: const Text('Balas Review',
            style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8C6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.review['nama_pasien'] ?? widget.review['name'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(widget.review['content'] ?? widget.review['review_text'] ?? '-'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tulis balasan...',
                  border: InputBorder.none,
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _isLoading ? null : _kirimBalasan,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Kirim Balasan'),
            )
          ],
        ),
      ),
    );
  }
}