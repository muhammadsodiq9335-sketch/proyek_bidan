import 'package:flutter/material.dart';

// SESUAIKAN IMPORT
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_tambah_jenis_pelayanan_screen.dart';
import 'admin_edit_pelayanan_screen.dart';
import '../mock_data.dart';
import 'admin_chat_list_screen.dart';

class AdminJenisPelayananScreen extends StatefulWidget {
  const AdminJenisPelayananScreen({super.key});

  @override
  State<AdminJenisPelayananScreen> createState() =>
      _AdminJenisPelayananScreenState();
}

class _AdminJenisPelayananScreenState
    extends State<AdminJenisPelayananScreen> {

  int selectedTab = 0; // 0 = Klinik, 1 = Home Care

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE6CF),

      /// ===== APPBAR =====
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Jenis Pelayanan",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.search, color: Colors.black),
          )
        ],
      ),

      /// ===== BODY =====
      body: Container(
        color: const Color(0xFFE6B8BE),
        child: Column(
          children: [

            /// ===== TAB =====
            Row(
              children: [
                _tabItem("Layanan Klinik", 0),
                _tabItem("Layanan Home Care", 1),
              ],
            ),

            const SizedBox(height: 10),

            /// ===== LIST =====
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: selectedTab == 0
                    ? _klinikList()
                    : _homeCareList(),
              ),
            ),

            /// ===== BUTTON TAMBAH =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminTambahJenisPelayananScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah Jenis Pemeriksaan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5F5F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),

      /// ===== BOTTOM NAV =====
      bottomNavigationBar: _bottomNav(context),
    );
  }

  /// ===== TAB ITEM =====
  Widget _tabItem(String title, int index) {
    bool isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// ===== CARD =====
  Widget _card(Color color, String title, String desc, String price, String tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminEditPelayananScreen(),
                        ),
                      );
                    },
                    child: const Icon(Icons.edit, size: 16),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.delete, size: 16),
                ],
              )
            ],
          ),

          const SizedBox(height: 4),

          Text(desc, style: const TextStyle(fontSize: 11)),

          const SizedBox(height: 8),

          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              tag,
              style: const TextStyle(fontSize: 10),
            ),
          )
        ],
      ),
    );
  }

  /// ===== DATA KLINIK =====
  List<Widget> _klinikList() {
    return [
      _card(
        const Color(0xFFF4C6CC),
        "Perinatal Care",
        "Perawatan menyeluruh bagi ibu dan bayi",
        "Rp 250.000",
        "Klinik Utama",
      ),
      _card(
        const Color(0xFFF8D7DA),
        "USG 2D/3D",
        "Pemeriksaan perkembangan janin",
        "Rp 350.000",
        "Radiologi",
      ),
      _card(
        const Color(0xFFFDE2E4),
        "Imunisasi Bayi",
        "Layanan vaksinasi dasar",
        "Rp 125.000",
        "Pediatrik",
      ),
      _card(
        const Color(0xFFFADADD),
        "Konsultasi KB",
        "Perencanaan keluarga",
        "Rp 150.000",
        "Kebidanan",
      ),
    ];
  }

  /// ===== DATA HOME CARE =====
  List<Widget> _homeCareList() {
    return [
      _card(
        const Color(0xFFF4C6CC),
        "Home Visit",
        "Kunjungan bidan ke rumah",
        "Rp 300.000",
        "Home Care",
      ),
      _card(
        const Color(0xFFF8D7DA),
        "Pijat Bayi",
        "Terapi pijat bayi di rumah",
        "Rp 200.000",
        "Home Care",
      ),
    ];
  }

  /// ===== BOTTOM NAV =====
  Widget _bottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        /// 🔥 STYLE BARU
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

        /// 🔥 NAVIGASI (TETAP PUNYA KAMU)
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
          }
          if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
          }
          if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminPasienScreen()));
          }
          if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
          }
        },

        /// 🔥 ICON (SAMA, TAPI SUDAH IKUT WARNA)
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Jadwal",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Pasien",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Pengaturan",
          ),
        ],
      ),
    );
  }
}