import 'package:flutter/material.dart';
import 'admin_balas_review_screen.dart';

class AdminReviewPasienScreen extends StatefulWidget {
  const AdminReviewPasienScreen({super.key});

  @override
  State<AdminReviewPasienScreen> createState() =>
      _AdminReviewPasienScreenState();
}

class _AdminReviewPasienScreenState extends State<AdminReviewPasienScreen> {
  final List<Review> reviews = [
    Review(
      name: 'SYIFA HADJU',
      rating: 5,
      date: '12 Jan 2026',
      content:
          'Bidan X sangat ramah dan penjelasannya sangat menenangkan. Fasilitasnya sangat bersih, membuat pengalaman USG pertama saya jadi sangat berkesan.',
      avatarColor: const Color(0xFFE8D5E0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0D8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F0D8),
        elevation: 0,
        title: const Text('Review Pasien', style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: reviews.map((r) => _buildReviewCard(r)).toList(),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
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
          /// HEADER
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                review.date,
                style: const TextStyle(fontSize: 10),
              )
            ],
          ),

          const SizedBox(height: 6),

          /// RATING
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 14,
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// REVIEW TEXT
          Text(review.content),

          const SizedBox(height: 10),

          /// BUTTON BALAS (kalau belum dibalas)
          if (review.adminReply == null)
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminBalasReviewScreen(review: review),
                  ),
                );
                setState(() {}); // refresh UI
              },
              child: const Text(
                '↩ Balas',
                style: TextStyle(color: Colors.black54),
              ),
            ),

          /// ===== ADMIN REPLY =====
          if (review.adminReply != null) ...[
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
                  /// HEADER ADMIN + DELETE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            review.adminReply = null;
                          });
                        },
                        child: const Icon(Icons.delete, size: 16, color: Colors.red),
                      )
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(review.adminReply!),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

/// MODEL
class Review {
  final String name;
  final int rating;
  final String date;
  final String content;
  final Color avatarColor;

  String? adminReply;

  Review({
    required this.name,
    required this.rating,
    required this.date,
    required this.content,
    required this.avatarColor,
    this.adminReply,
  });
}