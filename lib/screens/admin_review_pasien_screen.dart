import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_balas_review_screen.dart';

class AdminReviewPasienScreen extends StatefulWidget {
  const AdminReviewPasienScreen({super.key});

  @override
  State<AdminReviewPasienScreen> createState() => _AdminReviewPasienScreenState();
}

class _AdminReviewPasienScreenState extends State<AdminReviewPasienScreen> {
  final SupabaseService _supabaseService = SupabaseService();

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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Review Pasien', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        foregroundColor: _textPrimary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _accent));
          }
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text("Belum ada review", style: TextStyle(color: _textSecondary, fontSize: 14)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFFF0F5),
                child: Text(
                  ((review['nama_pasien'] ?? review['name'] ?? '-')[0]).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: _accent),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(review['nama_pasien'] ?? review['name'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
              ),
              Text(review['tanggal'] ?? review['date'] ?? '-', style: const TextStyle(fontSize: 10, color: _textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) => Icon(
              index < (review['rating'] ?? 0) ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xFFFFA726), size: 16,
            )),
          ),
          const SizedBox(height: 8),
          Text(review['content'] ?? review['review_text'] ?? '-', style: const TextStyle(color: _textSecondary)),
          const SizedBox(height: 10),
          if (review['admin_reply'] == null)
            GestureDetector(
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => AdminBalasReviewScreen(review: review)));
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(8)),
                child: const Text('↩ Balas', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          if (review['admin_reply'] != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _accent)),
                      GestureDetector(
                        onTap: () async {
                          if (review['id'] != null) {
                            await _supabaseService.hapusBalasanReview(review['id'].toString());
                            setState(() {});
                          }
                        },
                        child: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE53935)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(review['admin_reply']!, style: const TextStyle(color: _textPrimary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}