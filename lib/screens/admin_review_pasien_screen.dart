import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_balas_review_screen.dart';

class AdminReviewPasienScreen extends StatefulWidget {
  const AdminReviewPasienScreen({super.key});

  @override
  State<AdminReviewPasienScreen> createState() =>
      _AdminReviewPasienScreenState();
}

class _AdminReviewPasienScreenState extends State<AdminReviewPasienScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0D8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F0D8),
        elevation: 0,
        title: const Text('Review Pasien', style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) return const Center(child: Text("Belum ada review"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final r = reviews[index];
              return _buildReviewCard(r);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8C6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review['nama_pasien'] ?? review['name'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                review['tanggal'] ?? review['date'] ?? '-',
                style: const TextStyle(fontSize: 10),
              )
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(review['content'] ?? review['review_text'] ?? '-'),
          const SizedBox(height: 10),
          if (review['admin_reply'] == null)
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminBalasReviewScreen(review: review),
                  ),
                );
                setState(() {});
              },
              child: const Text(
                '↩ Balas',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          if (review['admin_reply'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAE6F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Admin',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (review['id'] != null) {
                            await _supabaseService.hapusBalasanReview(review['id'].toString());
                            setState(() {});
                          }
                        },
                        child: const Icon(Icons.delete, size: 16, color: Colors.red),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(review['admin_reply']!),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}