import 'package:flutter/material.dart';
import 'formulir_reservasi_screen.dart';
import 'sub_layanan_screen.dart';

class LayananScreen extends StatefulWidget {
  final int initialTab; // 0 = Klinik, 1 = Home Care
  const LayananScreen({super.key, this.initialTab = 0});

  @override
  State<LayananScreen> createState() => _LayananScreenState();
}

class _LayananScreenState extends State<LayananScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ─── DATA KLINIK ───────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _klinikIbuServices = [
    {
      'icon': Icons.pregnant_woman_outlined,
      'title': 'Periksa Hamil',
      'desc': 'Konsultasi rutin dan cek detak jantung janin',
      'price': 'Rp 100.000',
    },
    {
      'icon': Icons.favorite_border,
      'title': 'Periksa Nifas & Kesehatan Reproduksi',
      'desc': 'Pemulihan kesehatan ibu pasca melahirkan',
      'price': 'Rp 100.000',
    },
    {
      'icon': Icons.medical_services_outlined,
      'title': 'KB Suntik',
      'desc': 'Layanan kontrasepsi suntik oleh bidan profesional',
      'price': 'Rp 50.000',
    },
    {
      'icon': Icons.healing_outlined,
      'title': 'Pemasangan / Pelepasan Implan',
      'desc': 'Pemasangan dan pelepasan KB implan',
      'price': 'Rp 200.000',
    },
    {
      'icon': Icons.health_and_safety_outlined,
      'title': 'Pemasangan / Pelepasan IUD',
      'desc': 'Pemasangan dan pelepasan alat kontrasepsi IUD',
      'price': 'Rp 200.000',
    },
    {
      'icon': Icons.emoji_people_outlined,
      'title': 'Persalinan Normal Gentle Birth',
      'desc': 'Persalinan gentle birth dengan pendampingan bidan',
      'price': 'Rp 1.500.000',
    },
  ];

  final List<Map<String, dynamic>> _klinikAnakServices = [
    {
      'icon': Icons.monitor_weight_outlined,
      'title': 'Pemeriksaan Antropometri',
      'desc': 'Pengukuran tinggi badan, berat badan, dan lingkar kepala',
      'price': 'Rp 50.000',
    },
    {
      'icon': Icons.child_friendly_outlined,
      'title': 'Pemeriksaan Deteksi Dini Tumbuh Kembang',
      'desc': 'Skrining perkembangan anak secara menyeluruh',
      'price': 'Rp 100.000',
    },
    {
      'icon': Icons.vaccines_outlined,
      'title': 'Imunisasi Hb0 / BCG / DPT / PCV / MR',
      'desc': 'Pemberian vaksin dasar lengkap sesuai jadwal',
      'price': 'Rp 50.000',
    },
    {
      'icon': Icons.vaccines_outlined,
      'title': 'Imunisasi Polio / Rotavirus',
      'desc': 'Vaksinasi polio dan rotavirus untuk bayi',
      'price': 'Rp 30.000',
    },
    {
      'icon': Icons.child_care_outlined,
      'title': 'Tindik Bayi',
      'desc': 'Tindik telinga bayi yang aman dan steril',
      'price': 'Rp 75.000',
    },
  ];

  // ─── DATA HOME CARE ────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _homeCareIbuServices = [
    {
      'icon': Icons.school_outlined,
      'title': 'Kelas Privat Persiapan Persalinan / Menyusui / Newborn Care',
      'desc': 'Kelas privat persiapan menjadi orang tua baru',
      'price': 'Rp 300.000',
    },
    {
      'icon': Icons.self_improvement_outlined,
      'title': 'Prenatal Fit Yoga Privat',
      'desc': 'Yoga prenatal untuk relaksasi ibu hamil',
      'price': 'Rp 100.000',
    },
    {
      'icon': Icons.spa_outlined,
      'title': 'Pijat Hamil',
      'desc': 'Pijat relaksasi untuk ibu hamil oleh bidan terlatih',
      'price': 'Rp 150.000',
    },
    {
      'icon': Icons.spa_outlined,
      'title': 'Pijat Nifas',
      'desc': 'Pijat pemulihan pasca persalinan untuk ibu',
      'price': 'Rp 200.000',
    },
    {
      'icon': Icons.sports_handball_outlined,
      'title': 'Pijat Induksi Persalinan',
      'desc': 'Pijat untuk merangsang kontraksi alami',
      'price': 'Rp 250.000',
    },
    {
      'icon': Icons.water_drop_outlined,
      'title': 'Pijat Laktasi',
      'desc': 'Pijat untuk memperlancar produksi ASI',
      'price': 'Rp 250.000',
    },
    {
      'icon': Icons.record_voice_over_outlined,
      'title': 'Konseling Menyusui',
      'desc': 'Masalah menyusui, pumping, relaktasi & induksi laktasi',
      'price': 'Rp 150.000',
    },
  ];

  final List<Map<String, dynamic>> _homeCareByiServices = [
    {
      'icon': Icons.child_care_outlined,
      'title': 'Pijat Bayi 0–28 Hari',
      'desc': 'Pijat lembut untuk bayi baru lahir',
      'price': 'Rp 60.000',
    },
    {
      'icon': Icons.child_care_outlined,
      'title': 'Pijat Bayi 1–11 Bulan',
      'desc': 'Pijat stimulasi untuk pertumbuhan bayi',
      'price': 'Rp 75.000',
    },
    {
      'icon': Icons.child_care_outlined,
      'title': 'Pijat Anak 12–59 Bulan',
      'desc': 'Pijat stimulasi untuk tumbuh kembang balita',
      'price': 'Rp 85.000',
    },
    {
      'icon': Icons.content_cut_outlined,
      'title': 'Potong Kuku Bayi',
      'desc': 'Pemotongan kuku bayi yang aman dan nyaman',
      'price': 'Rp 30.000',
    },
    {
      'icon': Icons.face_outlined,
      'title': 'Cukur Rambut Bayi',
      'desc': 'Cukur rambut bayi pertama yang rapi',
      'price': 'Rp 50.000',
    },
    {
      'icon': Icons.hotel_outlined,
      'title': 'Paket Newborn Care 7 Hari',
      'desc': 'Perawatan bayi baru lahir selama 7 hari berturut-turut',
      'price': 'Rp 750.000',
    },
    {
      'icon': Icons.healing_outlined,
      'title': 'Pijat Terapi Bapil / Kolik / Stimulasi',
      'desc': 'Pijat terapi untuk bayi batuk pilek, kolik, dan stimulasi',
      'price': 'Rp 100.000',
    },
    {
      'icon': Icons.air_outlined,
      'title': 'Cuci Hidung',
      'desc': 'Pembersihan hidung bayi yang tersumbat',
      'price': 'Rp 50.000',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Layanan Bidan',
          style: TextStyle(
            color: Color(0xFF1B2E35),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Color(0xFF1B2E35)),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Banner
          _buildHeroBanner(),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00897B),
              unselectedLabelColor: Colors.black45,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              indicatorColor: const Color(0xFF00897B),
              indicatorWeight: 2.5,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_hospital_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Klinik'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Home Care'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── TAB KLINIK ──
                _buildKlinikTab(),
                // ── TAB HOME CARE ──
                _buildHomeCareTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── KLINIK TAB ─────────────────────────────────────────────────────────────
  Widget _buildKlinikTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const Text(
            'Pilih Kategori Layanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih kategori yang sesuai kebutuhan Anda',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 16),
          _buildKategoriCard(
            icon: Icons.pregnant_woman_outlined,
            title: 'Layanan Kesehatan Ibu',
            subtitle: 'Periksa hamil, nifas, KB, implan, IUD & persalinan',
            jumlahLayanan: _klinikIbuServices.length,
            color: const Color(0xFFF48FB1),
            gradientColors: const [Color(0xFFF48FB1), Color(0xFFF8BBD0)],
            services: _klinikIbuServices,
          ),
          const SizedBox(height: 14),
          _buildKategoriCard(
            icon: Icons.child_care_outlined,
            title: 'Layanan Kesehatan Anak',
            subtitle: 'Imunisasi, deteksi tumbuh kembang & tindik bayi',
            jumlahLayanan: _klinikAnakServices.length,
            color: const Color(0xFF26A69A),
            gradientColors: const [Color(0xFF26A69A), Color(0xFF80CBC4)],
            services: _klinikAnakServices,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildKategoriCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int jumlahLayanan,
    required Color color,
    required List<Color> gradientColors,
    required List<Map<String, dynamic>> services,
    bool isHomeCare = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubLayananScreen(
              kategori: title,
              kategoriIcon: icon,
              kategoriColor: color,
              services: services,
              isHomeCare: isHomeCare,
            ),
          ),
        );
      },
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
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Ikon besar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              // Teks
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
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$jumlahLayanan layanan tersedia →',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  // ─── HOME CARE TAB ───────────────────────────────────────────────────────────
  Widget _buildHomeCareTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info biaya transportasi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFFF9A825)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Semua layanan Home Care dikenakan biaya transportasi tambahan sesuai jarak.',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF795548),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const Text(
            'Pilih Kategori Layanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih kategori yang sesuai kebutuhan Anda',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 16),

          _buildKategoriCard(
            icon: Icons.spa_outlined,
            title: 'Layanan Komplementer Ibu',
            subtitle: 'Pijat hamil, nifas, laktasi, yoga privat & konseling',
            jumlahLayanan: _homeCareIbuServices.length,
            color: const Color(0xFFF48FB1),
            gradientColors: const [Color(0xFFF48FB1), Color(0xFFF8BBD0)],
            services: _homeCareIbuServices,
            isHomeCare: true,
          ),
          const SizedBox(height: 14),
          _buildKategoriCard(
            icon: Icons.child_care_outlined,
            title: 'Layanan Komplementer Bayi',
            subtitle: 'Pijat bayi, newborn care, cukur rambut & cuci hidung',
            jumlahLayanan: _homeCareByiServices.length,
            color: const Color(0xFF26A69A),
            gradientColors: const [Color(0xFF26A69A), Color(0xFF80CBC4)],
            services: _homeCareByiServices,
            isHomeCare: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── WIDGETS ─────────────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF48FB1), Color(0xFFF8BBD0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solusi Kesehatan Ibu & Anak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pelayanan profesional sepenuh hati',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.favorite, color: Colors.white54, size: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2E35),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service,
      {required bool isHomeCare}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormulirReservasiScreen(
              layanan: service['title'],
              isHomeCare: isHomeCare,
              harga: service['price'] ?? '-',
            ),
          ),
        );
      },
      child: Container(
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
              child: Icon(service['icon'] as IconData,
                  color: const Color(0xFF00897B), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['title'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service['desc'],
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    service['price'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00897B),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right, color: Colors.black26, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
