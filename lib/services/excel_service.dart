import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExcelService {
  static Future<void> downloadLaporan({
    required List<Map<String, dynamic>> data,
    required String period,
    required double totalRevenue,
    required int totalPatients,
  }) async {
    final excel = Excel.createExcel();
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    // Rename default sheet
    excel.rename('Sheet1', 'Laporan');
    final Sheet sheet = excel['Laporan'];

    // ── Styles ──
    final CellStyle titleStyle = CellStyle(
      bold: true,
      fontSize: 16,
      fontColorHex: ExcelColor.fromHexString('#880E4F'),
    );
    final CellStyle subTitleStyle = CellStyle(
      bold: false,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#555555'),
    );
    final CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#880E4F'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final CellStyle summaryLabelStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#FCE4EC'),
    );
    final CellStyle summaryValueStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#880E4F'),
    );
    final CellStyle evenRowStyle = CellStyle(
      fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#FFF5F8'),
    );
    final CellStyle oddRowStyle = CellStyle(
      fontSize: 9,
      backgroundColorHex: ExcelColor.white,
    );
    final CellStyle biayaEvenStyle = CellStyle(
      fontSize: 9,
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#FFF5F8'),
      fontColorHex: ExcelColor.fromHexString('#00695C'),
      horizontalAlign: HorizontalAlign.Right,
    );
    final CellStyle biayaOddStyle = CellStyle(
      fontSize: 9,
      bold: true,
      backgroundColorHex: ExcelColor.white,
      fontColorHex: ExcelColor.fromHexString('#00695C'),
      horizontalAlign: HorizontalAlign.Right,
    );
    final CellStyle centerStyle = CellStyle(
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
    );
    final CellStyle centerEvenStyle = CellStyle(
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#FFF5F8'),
    );

    // ── Row 1: Title ──
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('LAPORAN PELAYANAN BIDAN');
    titleCell.cellStyle = titleStyle;
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));

    // ── Row 2: Period ──
    final periodCell = sheet.cell(CellIndex.indexByString('A2'));
    periodCell.value = TextCellValue('Periode: $period');
    periodCell.cellStyle = subTitleStyle;
    sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('E2'));

    // ── Row 3: blank ──

    // ── Row 4-5: Summary ──
    _setCell(sheet, 'A4', 'Total Pasien', summaryLabelStyle);
    _setCell(sheet, 'B4', totalPatients.toString(), summaryValueStyle);
    _setCell(sheet, 'C4', 'Total Pendapatan', summaryLabelStyle);
    _setCell(sheet, 'D4', currencyFormat.format(totalRevenue), summaryValueStyle);

    // ── Row 6: blank ──

    // ── Row 7: Headers ──
    final headers = ['Tgl', 'Pasien', 'Bidan', 'Layanan', 'Biaya'];
    final headerCols = ['A', 'B', 'C', 'D', 'E'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByString('${headerCols[i]}7'));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // ── Rows 8+: Data ──
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final rowIndex = 8 + i; // 1-indexed in sheet
      final isEven = i.isEven;

      final tgl = item['tanggal'] != null
          ? DateFormat('dd/MM/yy').format(DateTime.parse(item['tanggal']))
          : '-';
      final pasien = item['nama_pasien'] ?? '-';
      final bidan = item['nama_bidan'] ?? '-';
      final layanan = item['layanan'] ?? '-';
      final biaya = currencyFormat.format(item['harga'] ?? 0);

      _setCell(sheet, 'A$rowIndex', tgl,
          isEven ? centerEvenStyle : centerStyle);
      _setCell(sheet, 'B$rowIndex', pasien,
          isEven ? evenRowStyle : oddRowStyle);
      _setCell(sheet, 'C$rowIndex', bidan,
          isEven ? evenRowStyle : oddRowStyle);
      _setCell(sheet, 'D$rowIndex', layanan,
          isEven ? evenRowStyle : oddRowStyle);
      _setCell(sheet, 'E$rowIndex', biaya,
          isEven ? biayaEvenStyle : biayaOddStyle);
    }

    // ── Column widths ──
    sheet.setColumnWidth(0, 14);  // Tgl
    sheet.setColumnWidth(1, 20);  // Pasien
    sheet.setColumnWidth(2, 24);  // Bidan
    sheet.setColumnWidth(3, 35);  // Layanan
    sheet.setColumnWidth(4, 20);  // Biaya

    // ── Footer row ──
    final footerRow = 8 + data.length + 1;
    final printedCell = sheet.cell(CellIndex.indexByString('A$footerRow'));
    printedCell.value = TextCellValue(
        'Dicetak pada: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}');
    printedCell.cellStyle = CellStyle(
      italic: true,
      fontSize: 9,
      fontColorHex: ExcelColor.fromHexString('#888888'),
    );
    sheet.merge(
      CellIndex.indexByString('A$footerRow'),
      CellIndex.indexByString('E$footerRow'),
    );

    // ── Download via web ──
    final bytes = excel.save();
    if (bytes == null) return;

    if (kIsWeb) {
      final blob = html.Blob(
        [Uint8List.fromList(bytes)],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
            'download',
            'laporan_bidan_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      try {
        String? targetPath;
        if (Platform.isAndroid) {
          final dir = Directory('/storage/emulated/0/Download');
          if (await dir.exists()) {
            targetPath = dir.path;
          } else {
            targetPath = (await getExternalStorageDirectory())?.path;
          }
        } else if (Platform.isIOS) {
          targetPath = (await getApplicationDocumentsDirectory()).path;
        } else {
          targetPath = (await getDownloadsDirectory())?.path ?? (await getApplicationDocumentsDirectory()).path;
        }

        if (targetPath == null) {
          targetPath = (await getTemporaryDirectory()).path;
        }

        final fileName = 'laporan_bidan_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
        final filePath = '$targetPath/$fileName';
        final file = File(filePath);

        try {
          await file.writeAsBytes(bytes, flush: true);
          await OpenFile.open(filePath);
        } catch (e) {
          // Fallback if permission denied
          final tempDir = await getTemporaryDirectory();
          final tempPath = '${tempDir.path}/$fileName';
          final tempFile = File(tempPath);
          await tempFile.writeAsBytes(bytes, flush: true);
          await OpenFile.open(tempPath);
        }
      } catch (e) {
        print('Error saving/opening excel: $e');
      }
    }
  }

  static void _setCell(Sheet sheet, String address, String value, CellStyle style) {
    final cell = sheet.cell(CellIndex.indexByString(address));
    cell.value = TextCellValue(value);
    cell.cellStyle = style;
  }
}
