import 'package:flutter/material.dart';
import 'admin_review_pasien_screen.dart';

class AdminBalasReviewScreen extends StatefulWidget {
  final Review review;

  const AdminBalasReviewScreen({super.key, required this.review});

  @override
  State<AdminBalasReviewScreen> createState() =>
      _AdminBalasReviewScreenState();
}

class _AdminBalasReviewScreenState
    extends State<AdminBalasReviewScreen> {
  final TextEditingController _controller = TextEditingController();

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

            /// REVIEW ASLI
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8C6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.review.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(widget.review.content),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TEXTFIELD
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

            /// BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  widget.review.adminReply = _controller.text;
                  Navigator.pop(context);
                }
              },
              child: const Text('Kirim Balasan'),
            )
          ],
        ),
      ),
    );
  }
}