import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../services/supabase_service.dart';
import '../services/pdf_service.dart';

class AdminLaporanScreen extends StatefulWidget {
  const AdminLaporanScreen({super.key});

  @override
  State<AdminLaporanScreen> createState() => _AdminLaporanScreenState();
}

class _AdminLaporanScreenState extends State<AdminLaporanScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;
  String _filterType = 'Bulanan'; // Harian, Bulanan, Tahunan

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await _supabaseService.getReportData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  double get _totalRevenue => _allData.fold(0, (sum, item) => sum + (item['harga'] ?? 0));
  int get _totalPatients => _allData.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Laporan Pelayanan', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B2E35))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFC2185B)),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC2185B)))
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummarySection(),
                  const SizedBox(height: 24),
                  _buildChartSection(),
                  const SizedBox(height: 24),
                  _buildRecentList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummarySection() {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Pasien',
            _totalPatients.toString(),
            Icons.people_alt_rounded,
            Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Pendapatan',
            currencyFormat.format(_totalRevenue),
            Icons.account_balance_wallet_rounded,
            Colors.green.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2E35))),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tren Kunjungan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _buildFilterDropdown(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(10)),
      child: DropdownButton<String>(
        value: _filterType,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFFC2185B)),
        items: ['Harian', 'Bulanan', 'Tahunan'].map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC2185B))),
          );
        }).toList(),
        onChanged: (val) => setState(() => _filterType = val!),
      ),
    );
  }

  Widget _buildChart() {
    final Map<String, int> groupedData = {};
    for (var item in _allData) {
      final date = DateTime.parse(item['tanggal']);
      String key;
      if (_filterType == 'Harian') {
        key = DateFormat('dd/MM').format(date);
      } else if (_filterType == 'Bulanan') {
        key = DateFormat('MMM').format(date);
      } else {
        key = DateFormat('yyyy').format(date);
      }
      groupedData[key] = (groupedData[key] ?? 0) + 1;
    }

    final List<String> keys = groupedData.keys.toList();
    if (keys.isEmpty) return const Center(child: Text('Tidak ada data'));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < keys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(keys[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(keys.length, (index) {
              return FlSpot(index.toDouble(), groupedData[keys[index]]!.toDouble());
            }),
            isCurved: true,
            color: const Color(0xFFC2185B),
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: const Color(0xFFC2185B).withOpacity(0.1)),
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList() {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ..._allData.reversed.take(10).map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.pink.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFC2185B), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nama_pasien'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(item['layanan'] ?? '-', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currencyFormat.format(item['harga'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00897B))),
                  Text(item['tanggal'] ?? '-', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _generatePdf() async {
    final pdfBytes = await PdfService.generateLaporan(
      data: _allData,
      period: 'Januari - Desember 2026', // Idealnya dinamis berdasarkan filter
      totalRevenue: _totalRevenue,
      totalPatients: _totalPatients,
    );
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }
}
