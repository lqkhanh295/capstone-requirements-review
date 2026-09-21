import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../models/models.dart';
import '../../infrastructure/export/pdf_report_generator.dart';
import '../../infrastructure/export/csv_report_generator.dart';

enum ExportFormat {
  pdf,
  csv,
}

class ExportResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;

  const ExportResult({
    required this.success,
    this.filePath,
    this.errorMessage,
  });
}

class _PdfGenerationPayload {
  final Document document;
  final PdfFontBytes? fontBytes;

  const _PdfGenerationPayload({
    required this.document,
    this.fontBytes,
  });
}

class ReportExportService {
  /// Generate PDF report in background isolate (No UI Freeze)
  static Future<Uint8List> generatePdfAsync(Document document) async {
    final fontBytes = await PDFReportGenerator.loadFonts();
    return await compute(
      _buildPdfIsolate,
      _PdfGenerationPayload(document: document, fontBytes: fontBytes),
    );
  }

  /// Generate CSV report string in background isolate (No UI Freeze)
  static Future<String> generateCsvAsync(Document document) async {
    return await compute(_buildCsvIsolate, document);
  }

  /// Top-level or static function for PDF compute isolate
  static Future<Uint8List> _buildPdfIsolate(_PdfGenerationPayload payload) async {
    return await PDFReportGenerator.generatePDF(
      payload.document,
      fontBytes: payload.fontBytes,
    );
  }

  /// Top-level or static function for CSV compute isolate
  static String _buildCsvIsolate(Document document) {
    return CSVReportGenerator.generateCSV(document);
  }

  /// Prompt user to save PDF or CSV report and write to file
  static Future<ExportResult> exportDocument({
    required Document document,
    required ExportFormat format,
    String? customPath,
  }) async {
    try {
      final isPdf = format == ExportFormat.pdf;
      final defaultFileName = isPdf
          ? '${document.name.replaceAll(RegExp(r'\.[^.]+$'), '')}_Review_Report.pdf'
          : '${document.name.replaceAll(RegExp(r'\.[^.]+$'), '')}_Review_Data.csv';

      String? savePath = customPath;

      savePath ??= await FilePicker.platform.saveFile(
        dialogTitle: isPdf ? 'Export PDF Report' : 'Export CSV Data',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: isPdf ? ['pdf'] : ['csv'],
      );

      if (savePath == null) {
        return const ExportResult(
          success: false,
          errorMessage: 'Export cancelled by user.',
        );
      }

      if (isPdf) {
        final pdfBytes = await generatePdfAsync(document);
        final file = File(savePath);
        await file.writeAsBytes(pdfBytes);
      } else {
        final csvString = await generateCsvAsync(document);
        final file = File(savePath);
        await file.writeAsString(csvString);
      }

      return ExportResult(
        success: true,
        filePath: savePath,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        errorMessage: 'Failed to export document: ${e.toString()}',
      );
    }
  }
}
