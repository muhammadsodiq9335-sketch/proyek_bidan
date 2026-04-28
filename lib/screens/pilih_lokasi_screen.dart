import 'package:flutter/material.dart';

class PilihLokasiScreen extends StatefulWidget {
  const PilihLokasiScreen({super.key});

  @override
  State<PilihLokasiScreen> createState() => _PilihLokasiScreenState();
}

class _PilihLokasiScreenState extends State<PilihLokasiScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingLocation = false;
  
  // Teks simulasi alamat yang terpilih
  String _selectedAddress = "Belum ada lokasi yang dipilih. Geser peta atau ketik lokasi.";

  void _useCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    // Simulasi jeda mencari GPS
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoadingLocation = false;
      _selectedAddress = "📍 Koordinat GPS Terkini\nKecamatan X, Kota Y";
      _searchController.text = "Lokasi Saya Saat Ini";
    });
  }

  void _kirimLokasi() {
    String finalLocation = _searchController.text.trim().isNotEmpty
        ? _searchController.text
        : _selectedAddress;

    // Kembali ke ChatScreen sambil membawa data teks lokasi
    Navigator.pop(context, "📍 $finalLocation");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text(
          'Pilih Lokasi',
          style: TextStyle(color: Color(0xFF1B2E35), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1B2E35)),
      ),
      body: Column(
        children: [
          // Bar Pencarian
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari jalan atau area...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _selectedAddress = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Tombol Lokasi Terkini
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: ElevatedButton.icon(
              onPressed: _useCurrentLocation,
              icon: _isLoadingLocation 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))
                  : const Icon(Icons.my_location, size: 18),
              label: Text(_isLoadingLocation ? "Mencari Lokasi..." : "Gunakan Lokasi Terkini"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // Area Dummy Peta
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gambar peta
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://i.ibb.co/3W6qWvW/maps-placeholder.png'), // gambar placeholder peta
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Efek overlay transparan agar teks mudah dibaca dan tombol jelas
                Container(color: Colors.white.withOpacity(0.3)),
                
                // Pin Peta yang bisa di "geser"
                const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Icon(Icons.location_on, size: 48, color: Colors.red),
                ),
              ],
            ),
          ),

          // Area Bawah (Informasi Lokasi Terpilih & Konfirmasi)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Lokasi Terpilih:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  _selectedAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B2E35)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _kirimLokasi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Kirim Lokasi Ini", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
