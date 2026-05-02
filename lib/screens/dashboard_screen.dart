import 'package:flutter/material.dart';
import 'layanan_screen.dart';
import 'login_screen.dart';
import 'riwayat_reservasi_screen.dart';
import 'notifikasi_screen.dart';
import 'pusat_bantuan_screen.dart';
import 'pengaturan_akun_screen.dart';
import 'chat_screen.dart';

import '../mock_data.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _BerandaPage(
        onTabChange: (index) => setState(() => _currentIndex = index),
      ),
      _ReservasiPage(),
      const ChatScreen(),
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
        onTap: (index) => setState(() => _currentIndex = index),
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
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'CHAT',
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// BERANDA PAGE
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _BerandaPage extends StatelessWidget {
  final Function(int) onTabChange;
  const _BerandaPage({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            _buildWelcomeSection(),
            _buildHeroBanner(context),
            _buildBidanSection(),
            _buildReservasiTerakhir(context),
            _buildTipsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Top Bar â”€â”€
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "MORA",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B2E35),
              letterSpacing: 2,
            ),
          ),
          Row(
            children: [
              _iconCircle(
                Icons.notifications_outlined,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotifikasiScreen())),
              ),
              const SizedBox(width: 8),
              _iconCircle(
                Icons.person_outline,
                onTap: () => onTabChange(4),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF546E7A)),
      ),
    );
  }

  // â”€â”€ Welcome â”€â”€
  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Halo,",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
              height: 1.2,
            ),
          ),
          Text(
            "${MockDatabase.currentUser?.nama.split(' ')[0] ?? 'Bunda'} ðŸ‘‹",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Jaga kesehatanmu hari ini ya, Bunda â¤ï¸",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withOpacity(0.5),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // â”€â”€ Hero Banner CTA â”€â”€
  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => onTabChange(1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00897B), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00897B).withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "âœ¨ Tersedia Layanan Klinik & Home Care",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Buat Reservasi\nSekarang",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Pilih Layanan â†’",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today_rounded,
                  color: Colors.white30, size: 72),
            ],
          ),
        ),
      ),
    );
  }


  // â”€â”€ Reservasi Terakhir â”€â”€
  Widget _buildReservasiTerakhir(BuildContext context) {
    final reservations = MockDatabase.userReservations;
    final bool hasReservasi = reservations.isNotEmpty;
    final last = hasReservasi ? reservations.first : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Reservasi Terakhir",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E35),
                ),
              ),
              if (hasReservasi)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RiwayatReservasiScreen()),
                  ),
                  child: const Text(
                    "Lihat Semua â†’",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00897B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!hasReservasi)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  const Text(
                    "Belum ada reservasi",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Buat reservasi pertamamu sekarang!",
                    style: TextStyle(fontSize: 11, color: Colors.black26),
                  ),
                ],
              ),
            )
          else
            _buildLastReservasiCard(last!),
        ],
      ),
    );
  }

  Widget _buildLastReservasiCard(Map<String, dynamic> r) {
    final String status = r['status'] ?? '-';
    final bool isWaiting = status == 'Menunggu Persetujuan';
    final bool isConfirmed = status == 'Dikonfirmasi';
    final Color statusColor = isWaiting
        ? const Color(0xFFF9A825)
        : isConfirmed
            ? const Color(0xFF00897B)
            : const Color(0xFF9E9E9E);
    final Color statusBg = isWaiting
        ? const Color(0xFFFFF8E1)
        : isConfirmed
            ? const Color(0xFFE0F2F1)
            : const Color(0xFFF5F5F5);
    final IconData statusIcon = isWaiting
        ? Icons.hourglass_top_rounded
        : isConfirmed
            ? Icons.check_circle_outline
            : Icons.info_outline;
    final bool isHomeCare = r['isHomeCare'] == true;

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
                child: Icon(
                  isHomeCare
                      ? Icons.home_work_outlined
                      : Icons.local_hospital_outlined,
                  color: const Color(0xFF00897B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['layanan'] ?? '-',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2E35),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHomeCare ? 'Home Care' : 'Klinik',
                      style: const TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      r['status'] ?? '-',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                r['tanggal'] ?? '-',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_outlined,
                  size: 13, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                r['jam'] ?? '-',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // â”€â”€ Bidan Kami â”€â”€
  Widget _buildBidanSection() {
    final List<Map<String, String>> bidanList = [
      {
        'nama': 'Bidan Siti',
        'spesialis': 'Persalinan & Nifas',
        'pengalaman': '8 Tahun',
        'avatar': 'https://i.pravatar.cc/150?img=47',
        'status': 'Tersedia',
      },
      {
        'nama': 'Bidan Maya',
        'spesialis': 'Imunisasi & Bayi',
        'pengalaman': '6 Tahun',
        'avatar': 'https://i.pravatar.cc/150?img=48',
        'status': 'Tersedia',
      },
      {
        'nama': 'Bidan Ani',
        'spesialis': 'Kehamilan & KB',
        'pengalaman': '10 Tahun',
        'avatar': 'https://i.pravatar.cc/150?img=45',
        'status': 'Tersedia',
      },
      {
        'nama': 'Bidan Nur Aeni',
        'spesialis': 'Home Care & Pijat',
        'pengalaman': '5 Tahun',
        'avatar': 'https://i.pravatar.cc/150?img=44',
        'status': 'Tersedia',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bidan Kami',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E35),
                  ),
                ),
                Text(
                  '${bidanList.length} Bidan Aktif',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00897B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
              'Tim bidan profesional siap melayani Bunda',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: bidanList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final bidan = bidanList[index];
                return _buildBidanCard(bidan);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidanCard(Map<String, String> bidan) {
    return Container(
      width: 145,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar + status dot
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00897B),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      bidan['avatar']!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE0F2F1),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF00897B),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Nama
            Text(
              bidan['nama']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E35),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),


          ],
        ),
      ),
    );
  }

  // â”€â”€ Tips Kesehatan â”€â”€
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tips Kesehatan Bunda",
            style: TextStyle(
              fontSize: 15,
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// RESERVASI PAGE
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ReservasiPage extends StatelessWidget {
  const _ReservasiPage();

  @override
  Widget build(BuildContext context) {
    final reservations = MockDatabase.userReservations;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            // Pilih Jenis Layanan
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Jenis Layanan",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Pilih cara bidan merawat Bunda",
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  const SizedBox(height: 16),
                  _buildLayananCard(
                    context: context,
                    icon: Icons.home_work_outlined,
                    title: "Home Care",
                    subtitle:
                        "Bidan datang ke rumah Bunda. Tersedia layanan pijat, konseling, perawatan bayi & lebih.",
                    badgeText: "8 Layanan",
                    gradientColors: const [Color(0xFF26A69A), Color(0xFF80CBC4)],
                    badgeColor: const Color(0xFF00897B),
                    tab: 1,
                  ),
                  const SizedBox(height: 14),
                  _buildLayananCard(
                    context: context,
                    icon: Icons.local_hospital_outlined,
                    title: "Datang ke Klinik",
                    subtitle:
                        "Kunjungi klinik kami. Tersedia periksa hamil, imunisasi, KB, persalinan & lebih.",
                    badgeText: "11 Layanan",
                    gradientColors: const [Color(0xFFF48FB1), Color(0xFFF8BBD0)],
                    badgeColor: const Color(0xFFF06292),
                    tab: 0,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Riwayat Reservasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Riwayat Reservasi",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2E35),
                        ),
                      ),
                      if (reservations.isNotEmpty)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const RiwayatReservasiScreen()),
                          ),
                          child: const Text(
                            "Lihat Semua â†’",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF00897B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (reservations.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 44, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          const Text(
                            "Belum ada reservasi",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black38,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Pilih layanan di atas untuk mulai",
                            style: TextStyle(
                                fontSize: 12, color: Colors.black26),
                          ),
                        ],
                      ),
                    )
                  else
                    ...reservations.reversed
                        .take(3)
                        .map((r) => _buildReservasiItem(r))
                        .toList(),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buat Reservasi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E35),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Halo, ${MockDatabase.currentUser?.nama.split(' ')[0] ?? 'Bunda'}! Mau layanan apa hari ini?",
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_outlined,
                color: Color(0xFF00897B), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildLayananCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required List<Color> gradientColors,
    required Color badgeColor,
    required int tab,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LayananScreen(initialTab: tab),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$badgeText tersedia â†’",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
      ),
    );
  }

  Widget _buildReservasiItem(Map<String, dynamic> r) {
    final bool isWaiting = r['status'] == 'Menunggu Persetujuan';
    final Color statusColor =
        isWaiting ? const Color(0xFFF9A825) : const Color(0xFF00897B);
    final Color statusBg =
        isWaiting ? const Color(0xFFFFF8E1) : const Color(0xFFE0F2F1);
    final bool isHomeCare = r['isHomeCare'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isHomeCare
                  ? Icons.home_work_outlined
                  : Icons.local_hospital_outlined,
              color: const Color(0xFF00897B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['layanan'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E35),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${r['tanggal'] ?? '-'} â€¢ ${r['jam'] ?? '-'}",
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              r['status'] ?? '-',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// ARTIKEL PAGE
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ArtikelPage extends StatelessWidget {
  const _ArtikelPage();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {
        "category": "NUTRITION",
        "title": "Optimal diet for the second trimester",
        "desc":
            "Fueling your baby's growth with the right nutrients. Cara menjaga keseimbangan gizi saat hamil trimester kedua agar bayi tumbuh sehat dan cerdas.",
        "image":
            "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&q=80",
        "date": "10 Apr 2026",
      },
      {
        "category": "MENTAL WELLNESS",
        "title": "The art of the Fourth Trimester transition",
        "desc":
            "Preparing your home and mind for the new baby. Memahami perubahan emosional pasca persalinan.",
        "image":
            "https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=400&q=80",
        "date": "11 Apr 2026",
      },
      {
        "category": "KESEHATAN",
        "title": "Persiapan melahirkan yang perlu kamu tahu",
        "desc":
            "Panduan lengkap untuk persiapan mental dan fisik menghadapi hari-H persalinan di klinik kami.",
        "image":
            "https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400&q=80",
        "date": "12 Apr 2026",
      },
      {
        "category": "NEWBORN CARE",
        "title": "Panduan menyusui eksklusif untuk ibu baru",
        "desc":
            "Tips sukses ASI eksklusif dan cara mengatasi masalah pelekatan pada bayi baru lahir.",
        "image":
            "https://images.unsplash.com/photo-1519689680058-324335c77eba?w=400&q=80",
        "date": "13 Apr 2026",
      },
      {
        "category": "WELLNESS",
        "title": "Pentingnya senam hamil secara rutin",
        "desc":
            "Olahraga ringan yang sangat dianjurkan untuk mempersiapkan otot panggul sebelum melahirkan.",
        "image":
            "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&q=80",
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
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4))
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 160,
                            color: const Color(0xFFEEEEEE),
                            child: const Icon(Icons.image_outlined,
                                color: Colors.black26, size: 40),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
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
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black45),
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// PROFIL PAGE
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
                      border:
                          Border.all(color: const Color(0xFF00897B), width: 3),
                      image: const DecorationImage(
                        image: NetworkImage(
                            "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80"),
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
            Column(
              children: [
                Text(
                  MockDatabase.currentUser?.nama ?? 'Mama',
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
              ]
            ),
            const SizedBox(height: 30),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _buildProfileMenu(context, Icons.favorite_border,
                      "Data Kesehatan Kehamilan",
                      isComingSoon: true),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    context,
                    Icons.history,
                    "Riwayat Reservasi",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const RiwayatReservasiScreen())),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    context,
                    Icons.notifications_none,
                    "Notifikasi",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotifikasiScreen())),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    context,
                    Icons.help_outline,
                    "Pusat Bantuan",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PusatBantuanScreen())),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    context,
                    Icons.settings_outlined,
                    "Pengaturan Akun",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const PengaturanAkunScreen())),
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
                    MockDatabase.currentUser = null;
                    if (!context.mounted) return;
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    "Keluar",
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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

  Widget _buildProfileMenu(BuildContext context, IconData icon, String title,
      {bool isComingSoon = false, VoidCallback? onTap}) {
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
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber),
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
