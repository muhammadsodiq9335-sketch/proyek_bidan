import 'package:flutter/material.dart';
import 'layanan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void _goToReservasi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LayananScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _BerandaPage(onReservasi: _goToReservasi),
      _PlaceholderPage(label: "Reservasi"),
      _PlaceholderPage(label: "Artikel"),
      _PlaceholderPage(label: "Profil"),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LayananScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: const Color(0xFFB0BEC5),
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          letterSpacing: 0.5,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'BERANDA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'RESERVASI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'ARTIKEL',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'PROFIL',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BERANDA PAGE
// ─────────────────────────────────────────────
class _BerandaPage extends StatelessWidget {
  final VoidCallback onReservasi;
  const _BerandaPage({required this.onReservasi});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            _buildTopBar(),

            // Welcome Section
            _buildWelcomeSection(),

            // Layanan Section
            _buildLayananSection(context),

            // Tips Kesehatan Section
            _buildTipsSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          const Text(
            "MORA",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B2E35),
              letterSpacing: 2,
            ),
          ),
          // Icon buttons
          Row(
            children: [
              _iconCircle(Icons.notifications_outlined),
              const SizedBox(width: 8),
              _iconCircle(Icons.person_outline),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF546E7A)),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome home,",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
              height: 1.2,
            ),
          ),
          const Text(
            "Mama.",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Selamat datang kembali. Ada yang bisa kami bantu hari ini?",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withOpacity(0.5),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLayananSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pilih Layanan Bunda",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
            ),
          ),
          const SizedBox(height: 12),
          _buildLayananCard(
            context: context,
            icon: Icons.home_work_outlined,
            title: "Home Care",
            subtitle: "Professional midwifery in the comfort of your sanctuary.",
            tab: 1,
          ),
          const SizedBox(height: 12),
          _buildLayananCard(
            context: context,
            icon: Icons.local_hospital_outlined,
            title: "Datang Klinik Langsung",
            subtitle: "Visit our modern facility for scheduled check-ups and care.",
            tab: 0,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLayananCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required int tab,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF00897B), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2E35),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LayananScreen(initialTab: tab),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Buat Reservasi",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    final List<Map<String, String>> articles = [
      {
        "category": "NUTRITION",
        "title": "Optimal diet for the second trimester",
        "desc": "Fueling your baby's growth with...",
        "image":
            "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=300&q=80",
      },
      {
        "category": "MENTAL WELLNESS",
        "title": "The art of the Fourth Trimester transition",
        "desc": "Preparing your home and mind...",
        "image":
            "https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=300&q=80",
      },
      {
        "category": "KESEHATAN",
        "title": "Persiapan melahirkan yang perlu kamu tahu",
        "desc": "Panduan lengkap untuk persiapan...",
        "image":
            "https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=300&q=80",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tips Kesehatan Bunda",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
            ),
          ),
          const SizedBox(height: 12),
          ...articles.map((article) => _buildArticleCard(article)).toList(),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, String> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            child: Image.network(
              article["image"]!,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 90,
                height: 90,
                color: const Color(0xFFEEEEEE),
                child: const Icon(Icons.image_outlined, color: Colors.black26),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article["category"]!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00897B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article["title"]!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    article["desc"]!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PLACEHOLDER untuk halaman lain
// ─────────────────────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_outlined, size: 60, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            "Halaman $label\nSedang dalam pengembangan",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black45, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
