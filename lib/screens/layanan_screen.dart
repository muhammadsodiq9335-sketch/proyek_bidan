import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
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
  final SupabaseService _supabaseService = SupabaseService();

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getJenisPelayanan(),
        builder: (context, snapshot) {
          final allServices = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter data berdasarkan kategori
          // Filter data berdasarkan kategori (Exact Match)
          final klinikIbu = allServices.where((s) => s['kategori'] == 'Kesehatan Ibu' && (s['is_home_care'] == false)).toList();
          final klinikAnak = allServices.where((s) => s['kategori'] == 'Kesehatan Anak' && (s['is_home_care'] == false)).toList();
          final homeCareIbu = allServices.where((s) => s['kategori'] == 'Komplementer Ibu' && (s['is_home_care'] == true)).toList();
          final homeCareAnak = allServices.where((s) => s['kategori'] == 'Komplementer Bayi' && (s['is_home_care'] == true)).toList();

          // Fallback if data is empty (use default categories for UI)
          return Column(
            children: [
              _buildHeroBanner(),
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF00897B),
                  unselectedLabelColor: Colors.black45,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildKlinikTab(klinikIbu, klinikAnak),
                    _buildHomeCareTab(homeCareIbu, homeCareAnak),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── KLINIK TAB ─────────────────────────────────────────────────────────────
  Widget _buildKlinikTab(List<Map<String, dynamic>> ibu, List<Map<String, dynamic>> anak) {
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
            jumlahLayanan: ibu.length,
            color: const Color(0xFFF48FB1),
            gradientColors: const [Color(0xFFF48FB1), Color(0xFFF8BBD0)],
            services: ibu,
          ),
          const SizedBox(height: 14),
          _buildKategoriCard(
            icon: Icons.child_care_outlined,
            title: 'Layanan Kesehatan Anak',
            subtitle: 'Imunisasi, deteksi tumbuh kembang & tindik bayi',
            jumlahLayanan: anak.length,
            color: const Color(0xFF26A69A),
            gradientColors: const [Color(0xFF26A69A), Color(0xFF80CBC4)],
            services: anak,
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
  Widget _buildHomeCareTab(List<Map<String, dynamic>> ibu, List<Map<String, dynamic>> anak) {
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
            jumlahLayanan: ibu.length,
            color: const Color(0xFFF48FB1),
            gradientColors: const [Color(0xFFF48FB1), Color(0xFFF8BBD0)],
            services: ibu,
            isHomeCare: true,
          ),
          const SizedBox(height: 14),
          _buildKategoriCard(
            icon: Icons.child_care_outlined,
            title: 'Layanan Komplementer Bayi',
            subtitle: 'Pijat bayi, newborn care, cukur rambut & cuci hidung',
            jumlahLayanan: anak.length,
            color: const Color(0xFF26A69A),
            gradientColors: const [Color(0xFF26A69A), Color(0xFF80CBC4)],
            services: anak,
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

}
