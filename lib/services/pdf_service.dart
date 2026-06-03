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
final List<Map<String, dynamic>> trimmedData = data.isNotEmpty ? data.sublist(0, data.length - 1) : data;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(period),
          pw.SizedBox(height: 20),
          _buildSummary(totalPatients, totalRevenue, currencyFormat),
          pw.SizedBox(height: 20),
          _buildTable(trimmedData, currencyFormat),
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 40),
            child: pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Column(
                children: [
                  pw.Text('Dicetak pada: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}', style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 40),
                  pw.Text('____________________', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
    const cellStyle = pw.TextStyle(fontSize: 9);
    final altRowColor = PdfColors.pink50;

    // Column widths: Tgl, Pasien, Bidan, Layanan, Biaya
    final columnWidths = {
      0: const pw.FixedColumnWidth(50),   // Tgl
      1: const pw.FlexColumnWidth(1.8),   // Pasien
      2: const pw.FlexColumnWidth(2.2),   // Bidan
      3: const pw.FlexColumnWidth(2.5),   // Layanan
      4: const pw.FixedColumnWidth(72),   // Biaya
    };

    // Headers — semua di-center
    final headers = ['Tgl', 'Pasien', 'Bidan', 'Layanan', 'Biaya'];
    final headerRow = pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.pink800),
      children: headers.map((h) =>
        pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Text(h, style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          )),
        ),
      ).toList(),
    );

    // Data rows
    final dataRows = data.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      final isAlt = i.isOdd;
      return pw.TableRow(
        decoration: pw.BoxDecoration(color: isAlt ? altRowColor : PdfColors.white),
        children: [
          // Tgl — center
          _cell(
            item['tanggal'] != null
                ? DateFormat('dd/MM/yy').format(DateTime.parse(item['tanggal']))
                : '-',
            cellStyle,
            pw.Alignment.center,
          ),
          // Pasien — center
          _cell(item['nama_pasien'] ?? '-', cellStyle, pw.Alignment.center),
          // Bidan — center
          _cell(item['nama_bidan'] ?? '-', cellStyle, pw.Alignment.center),
          // Layanan — left (karena teks bisa panjang/multiline)
          _cell(item['layanan'] ?? '-', cellStyle, pw.Alignment.centerLeft),
          // Biaya — right
          _cell(format.format(item['harga'] ?? 0), cellStyle, pw.Alignment.centerRight),
        ],
      );
    }).toList();

    return pw.Table(
      columnWidths: columnWidths,
      border: pw.TableBorder(
        bottom: const pw.BorderSide(color: PdfColors.pink300, width: 0.8),
        horizontalInside: const pw.BorderSide(color: PdfColors.pink100, width: 0.5),
        verticalInside: const pw.BorderSide(color: PdfColors.pink100, width: 0.3),
      ),
      children: [headerRow, ...dataRows],
    );
  }

  static pw.Widget _cell(String text, pw.TextStyle style, pw.Alignment alignment) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      alignment: alignment,
      child: pw.Text(text, style: style),
    );
  }
}
