import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class PilihLokasiScreen extends StatefulWidget {
  const PilihLokasiScreen({super.key});

  @override
  State<PilihLokasiScreen> createState() => _PilihLokasiScreenState();
}

class _PilihLokasiScreenState extends State<PilihLokasiScreen> {
  // Default: Indonesia tengah
  LatLng _currentLatLng = const LatLng(-2.5489, 118.0149);
  final MapController _mapController = MapController();
  bool _isLoadingLocation = false;
  bool _isGeocoding = false;
  String _selectedAddress = 'Ketuk peta untuk memilih lokasi';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    // Langsung minta lokasi saat layar dibuka
    _getCurrentLocation();
  }

  // ── Ambil GPS terkini ──
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Layanan lokasi tidak aktif. Aktifkan GPS terlebih dahulu.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Izin lokasi ditolak.');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Izin lokasi diblokir permanen. Aktifkan di pengaturan browser.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final newLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLatLng = newLatLng;
        _isLoadingLocation = false;
      });
      _mapController.move(newLatLng, 16.0);
      _reverseGeocode(newLatLng);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      _showSnackBar('Gagal mendapatkan lokasi: $e');
    }
  }

  // ── Reverse Geocoding via Nominatim (OpenStreetMap, gratis) ──
  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() => _isGeocoding = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${latLng.latitude}&lon=${latLng.longitude}'
        '&format=json&accept-language=id',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'MoraReservasiBidan/1.0'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['display_name'] ?? 'Lokasi tidak dikenali';
        // Potong alamat agar tidak terlalu panjang
        final parts = address.split(',');
        final shortAddress = parts.take(4).join(',').trim();
        setState(() {
          _selectedAddress = shortAddress;
          _searchText = shortAddress;
        });
      } else {
        setState(() => _selectedAddress = 'Koordinat: ${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}');
      }
    } catch (_) {
      setState(() => _selectedAddress = 'Koordinat: ${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}');
    } finally {
      setState(() => _isGeocoding = false);
    }
  }

  // ── Kirim lokasi ke ChatScreen ──
  void _kirimLokasi() {
    if (_selectedAddress == 'Ketuk peta untuk memilih lokasi') {
      _showSnackBar('Pilih lokasi terlebih dahulu');
      return;
    }
    Navigator.pop(context, '📍 $_selectedAddress');
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text(
          'Pilih Lokasi',
          style: TextStyle(
            color: Color(0xFF1B2E35),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1B2E35)),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Ketuk peta untuk memilih lokasi',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _isGeocoding
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              controller: TextEditingController(text: _searchText),
            ),
          ),

          // ── Tombol Lokasi Terkini ──
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(
                _isLoadingLocation ? 'Mencari Lokasi GPS...' : 'Gunakan Lokasi Terkini',
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // ── Peta Interaktif OpenStreetMap ──
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLatLng,
                    initialZoom: 13.0,
                    minZoom: 4.0,
                    maxZoom: 19.0,
                    onTap: (tapPosition, latLng) {
                      setState(() => _currentLatLng = latLng);
                      _reverseGeocode(latLng);
                    },
                  ),
                  children: [
                    // Layer tile OpenStreetMap
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.mora.proyek_bidan',
                      maxZoom: 19,
                    ),
                    // Layer marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLatLng,
                          width: 60,
                          height: 70,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00897B),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                  ],
                                ),
                                child: const Text(
                                  'Lokasi',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.location_on, size: 36, color: Color(0xFFE53935)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Tombol Zoom ──
                Positioned(
                  right: 12,
                  bottom: 16,
                  child: Column(
                    children: [
                      _mapButton(Icons.add, () => _mapController.move(
                        _mapController.camera.center,
                        (_mapController.camera.zoom + 1).clamp(4, 19),
                      )),
                      const SizedBox(height: 4),
                      _mapButton(Icons.remove, () => _mapController.move(
                        _mapController.camera.center,
                        (_mapController.camera.zoom - 1).clamp(4, 19),
                      )),
                    ],
                  ),
                ),

                // ── Hint Geser ──
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Ketuk peta untuk memilih lokasi',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Panel Bawah ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on, color: Color(0xFF00897B), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Lokasi Terpilih',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _isGeocoding
                    ? const Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Mendapatkan alamat...', style: TextStyle(fontSize: 13, color: Colors.black45)),
                        ],
                      )
                    : Text(
                        _selectedAddress,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1B2E35),
                          height: 1.4,
                        ),
                      ),
                const SizedBox(height: 8),
                Text(
                  'Koordinat: ${_currentLatLng.latitude.toStringAsFixed(5)}, ${_currentLatLng.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(fontSize: 10, color: Colors.black38),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_isLoadingLocation || _isGeocoding) ? null : _kirimLokasi,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Kirim Lokasi Ini',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1B2E35)),
      ),
    );
  }
}
