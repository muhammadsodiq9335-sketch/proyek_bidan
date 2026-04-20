import 'package:flutter/material.dart';
import 'layanan_screen.dart';
import 'login_screen.dart';
import 'riwayat_reservasi_screen.dart';
import 'notifikasi_screen.dart';
import 'pusat_bantuan_screen.dart';
import 'pengaturan_akun_screen.dart';
import '../mock_data.dart';

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
      const SizedBox(), // Tab 1 is intercepted by BottomNavBar onTap
      const _ArtikelPage(),
      const _ProfilPage(),
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
          Text(
            MockDatabase.currentUser != null 
                ? "${MockDatabase.currentUser!.nama.split(' ')[0]}." 
                : "Mama.",
            style: const TextStyle(
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
          const SizedBox(height: 12),
          _buildComingSoonCard(
            icon: Icons.book_outlined,
            title: "Jurnal Bunda",
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

  Widget _buildComingSoonCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black26, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black26,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "PENGEMBANGAN",
              style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black38),
            ),
          ),
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
// ARTIKEL PAGE
// ─────────────────────────────────────────────
class _ArtikelPage extends StatelessWidget {
  const _ArtikelPage();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {
        "category": "NUTRITION",
        "title": "Optimal diet for the second trimester",
        "desc": "Fueling your baby's growth with the right nutrients. Cara menjaga keseimbangan gizi saat hamil trimester kedua agar bayi tumbuh sehat dan cerdas.",
        "image": "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&q=80",
        "date": "10 Apr 2026",
      },
      {
        "category": "MENTAL WELLNESS",
        "title": "The art of the Fourth Trimester transition",
        "desc": "Preparing your home and mind for the new baby. Memahami perubahan emosional pasca persalinan.",
        "image": "https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=400&q=80",
        "date": "11 Apr 2026",
      },
      {
        "category": "KESEHATAN",
        "title": "Persiapan melahirkan yang perlu kamu tahu",
        "desc": "Panduan lengkap untuk persiapan mental dan fisik menghadapi hari-H persalinan di klinik kami.",
        "image": "https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400&q=80",
        "date": "12 Apr 2026",
      },
      {
        "category": "NEWBORN CARE",
        "title": "Panduan menyusui eksklusif untuk ibu baru",
        "desc": "Tips sukses ASI eksklusif dan cara mengatasi masalah pelekatan pada bayi baru lahir.",
        "image": "https://images.unsplash.com/photo-1519689680058-324335c77eba?w=400&q=80",
        "date": "13 Apr 2026",
      },
      {
        "category": "WELLNESS",
        "title": "Pentingnya senam hamil secara rutin",
        "desc": "Olahraga ringan yang sangat dianjurkan untuk mempersiapkan otot panggul sebelum melahirkan.",
        "image": "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&q=80",
        "date": "14 Apr 2026",
      },
    ];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Artikel Kesehatan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E35),
                  ),
                ),
                Icon(Icons.search, color: Color(0xFF546E7A)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          article["image"]!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 160,
                            color: const Color(0xFFEEEEEE),
                            child: const Icon(Icons.image_outlined, color: Colors.black26, size: 40),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2F1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    article["category"]!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00897B),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  article["date"]!,
                                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              article["title"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2E35),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              article["desc"]!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROFIL PAGE
// ─────────────────────────────────────────────
class _ProfilPage extends StatelessWidget {
  const _ProfilPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Avatar
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00897B), width: 3),
                      image: const DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00897B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              MockDatabase.currentUser?.nama ?? "Mama",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E35),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              MockDatabase.currentUser?.email ?? "+62 812-3456-7890",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _buildProfileMenu(Icons.favorite_border, "Data Kesehatan Kehamilan", isComingSoon: true),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    Icons.history,
                    "Riwayat Reservasi",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatReservasiScreen())),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    Icons.notifications_none,
                    "Notifikasi",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen())),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    Icons.help_outline,
                    "Pusat Bantuan",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PusatBantuanScreen())),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    Icons.settings_outlined,
                    "Pengaturan Akun",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PengaturanAkunScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Benar-benar logout dan kembali ke login
                    MockDatabase.currentUser = null;
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    "Keluar",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, {bool isComingSoon = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF00897B), size: 20),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isComingSoon ? Colors.black26 : const Color(0xFF1B2E35),
            ),
          ),
          if (isComingSoon) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "COMING SOON",
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: isComingSoon ? null : (onTap ?? () {}),
    );
  }
}
