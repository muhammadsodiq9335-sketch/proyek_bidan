import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<Uint8List> generateLaporan({
    required List<Map<String, dynamic>> data,
    required String period,
    required double totalRevenue,
    required int totalPatients,
  }) async {
    final pdf = pw.Document();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(period),
          pw.SizedBox(height: 20),
          _buildSummary(totalPatients, totalRevenue, currencyFormat),
          pw.SizedBox(height: 20),
          _buildTable(data, currencyFormat),
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 40),
            child: pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Column(
                children: [
                  pw.Text('Dicetak pada: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 40),
                  pw.Text('____________________', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Admin Bidan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String period) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('LAPORAN PELAYANAN BIDAN', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.pink900)),
        pw.SizedBox(height: 8),
        pw.Text('Periode: $period', style: const pw.TextStyle(fontSize: 14)),
        pw.Divider(thickness: 2, color: PdfColors.pink100),
      ],
    );
  }

  static pw.Widget _buildSummary(int totalPatients, double totalRevenue, NumberFormat format) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        _buildSummaryBox('Total Pasien', totalPatients.toString(), PdfColors.blue100),
        pw.SizedBox(width: 20),
        _buildSummaryBox('Total Pendapatan', format.format(totalRevenue), PdfColors.green100),
      ],
    );
  }

  static pw.Widget _buildSummaryBox(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<Map<String, dynamic>> data, NumberFormat format) {
    final headers = ['Tgl', 'Pasien', 'Layanan', 'Biaya'];
    
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data.map((item) {
        return [
          item['tanggal'] != null ? DateFormat('dd/MM/yy').format(DateTime.parse(item['tanggal'])) : '-',
          item['nama_pasien'] ?? '-',
          item['layanan'] ?? '-',
          format.format(item['harga'] ?? 0),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.pink800),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
    );
  }
}
