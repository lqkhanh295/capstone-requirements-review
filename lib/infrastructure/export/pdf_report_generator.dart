import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/models.dart';
import '../../domain/services/dashboard_service.dart';

class PdfFontBytes {
  final Uint8List regular;
  final Uint8List bold;
  final Uint8List italic;

  const PdfFontBytes({
    required this.regular,
    required this.bold,
    required this.italic,
  });
}

class PDFReportGenerator {
  /// Loads Inter TTF font bytes from assets or local filesystem for full Unicode & Vietnamese support.
  static Future<PdfFontBytes?> loadFonts() async {
    try {
      final regData = await rootBundle.load('assets/fonts/Inter-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/Inter-Bold.ttf');
      final italicData = await rootBundle.load('assets/fonts/Inter-Italic.ttf');
      return PdfFontBytes(
        regular: regData.buffer.asUint8List(),
        bold: boldData.buffer.asUint8List(),
        italic: italicData.buffer.asUint8List(),
      );
    } catch (_) {
      try {
        final regFile = File('assets/fonts/Inter-Regular.ttf');
        final boldFile = File('assets/fonts/Inter-Bold.ttf');
        final italicFile = File('assets/fonts/Inter-Italic.ttf');
        if (await regFile.exists() && await boldFile.exists() && await italicFile.exists()) {
          return PdfFontBytes(
            regular: await regFile.readAsBytes(),
            bold: await boldFile.readAsBytes(),
            italic: await italicFile.readAsBytes(),
          );
        }
      } catch (_) {}
    }
    return null;
  }

  /// Sanitizes text for PDF rendering by normalizing box-drawing characters
  /// and stripping unprintable control sequences that cannot be rendered.
  static String sanitizeText(String text) {
    if (text.isEmpty) return text;
    return text
        // Normalize box-drawing characters to clean ASCII table borders
        .replaceAll(RegExp(r'[\u2502\u2503\u2551]'), '|')
        .replaceAll(RegExp(r'[\u2500\u2501\u2550]'), '-')
        .replaceAll(RegExp(r'[\u250C-\u254B\u2552-\u257F]'), '+')
        // Clean unprintable control characters & replacement character
        .replaceAll('\uFFFD', '')
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
  }

  /// Generates printable PDF document bytes for a given Document.
  static Future<Uint8List> generatePDF(
    Document document, {
    PdfFontBytes? fontBytes,
  }) async {
    fontBytes ??= await loadFonts();

    pw.ThemeData theme;
    if (fontBytes != null) {
      final baseFont = pw.Font.ttf(ByteData.sublistView(fontBytes.regular));
      final boldFont = pw.Font.ttf(ByteData.sublistView(fontBytes.bold));
      final italicFont = pw.Font.ttf(ByteData.sublistView(fontBytes.italic));
      theme = pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
        italic: italicFont,
      );
    } else {
      theme = pw.ThemeData();
    }

    final sanitizedDocName = sanitizeText(document.name);

    final pdf = pw.Document(
      title: 'Requirements Review - $sanitizedDocName',
      author: 'Capstone Requirements Review Tool',
      theme: theme,
    );

    final summary = DashboardService.calculateSummary(document);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = dateFormat.format(document.importedAt);

    // Primary Colors matching design tokens
    final primaryColor = PdfColor.fromHex('#3157D5');
    final passedColor = PdfColor.fromHex('#27845C');
    final needsReviewColor = PdfColor.fromHex('#B7791F');
    final failedColor = PdfColor.fromHex('#C84646');
    final neutralBg = PdfColor.fromHex('#F7F8FA');
    final borderCol = PdfColor.fromHex('#E2E5E9');
    final textDark = PdfColor.fromHex('#171A1F');
    final textMuted = PdfColor.fromHex('#656B75');

    PdfColor scoreColor(int score) {
      if (score >= 80) return passedColor;
      if (score >= 60) return needsReviewColor;
      return failedColor;
    }

    // Cover Page / Header
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.only(bottom: 6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'CAPSTONE REQUIREMENTS REVIEW REPORT',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  'Document: $sanitizedDocName',
                  style: pw.TextStyle(fontSize: 9, color: textMuted),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: textMuted),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Title Block
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: neutralBg,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: borderCol),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Requirements Evaluation Report',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('Document Name: $sanitizedDocName',
                          style: pw.TextStyle(fontSize: 11, color: textDark)),
                      pw.Text('Review Date: $formattedDate',
                          style: pw.TextStyle(fontSize: 10, color: textMuted)),
                      pw.Text('Total Requirements: ${document.requirements.length}',
                          style: pw.TextStyle(fontSize: 10, color: textMuted)),
                    ],
                  ),
                  // Overall Score Box
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: pw.BoxDecoration(
                      color: scoreColor(summary.overallQualityScore),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          '${summary.overallQualityScore}',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'Overall Score',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Section 1: Executive Summary Table
            pw.Text(
              '1. Status Classification Summary',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: textDark,
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: borderCol, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: neutralBg),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Status',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Count',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Percentage',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Passed',
                        style: pw.TextStyle(
                            color: passedColor, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('${summary.passedCount}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                        '${summary.passedPercentage.toStringAsFixed(1)}%'),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Needs Review',
                        style: pw.TextStyle(
                            color: needsReviewColor,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('${summary.needsReviewCount}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                        '${summary.needsReviewPercentage.toStringAsFixed(1)}%'),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Failed',
                        style: pw.TextStyle(
                            color: failedColor, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('${summary.failedCount}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                        '${summary.failedPercentage.toStringAsFixed(1)}%'),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Not Reviewed',
                        style: pw.TextStyle(color: textMuted)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('${summary.notReviewedCount}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                        '${summary.notReviewedPercentage.toStringAsFixed(1)}%'),
                  ),
                ]),
              ],
            ),

            pw.SizedBox(height: 20),

            // Section 2: Requirement Detailed List
            pw.Text(
              '2. Detailed Requirements Assessment',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: textDark,
              ),
            ),
            pw.SizedBox(height: 10),

            ...document.requirements.map((req) {
              final review = req.review;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 14),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: borderCol, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Req Header
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Row(
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: pw.BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: pw.BorderRadius.circular(3),
                                ),
                                child: pw.Text(
                                  sanitizeText(req.id),
                                  style: pw.TextStyle(
                                      color: PdfColors.white,
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                              pw.SizedBox(width: 8),
                              pw.Expanded(
                                child: pw.Text(
                                  sanitizeText(req.title),
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Text(
                          'Status: ${req.status.label}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: req.status == ReviewStatus.passed
                                ? passedColor
                                : req.status == ReviewStatus.failed
                                    ? failedColor
                                    : needsReviewColor,
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 6),
                    pw.Text('Type: ${req.type.label}',
                        style: pw.TextStyle(fontSize: 9, color: textMuted)),
                    pw.SizedBox(height: 4),
                    pw.Text(sanitizeText(req.description),
                        style: pw.TextStyle(fontSize: 9.5, color: textDark)),

                    if (review != null) ...[
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          color: neutralBg,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                                'AI Overall Score: ${review.overallScore}/100',
                                style: pw.TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: scoreColor(review.overallScore))),
                            pw.Text(
                              'Clarity: ${review.scores.clarity} | Completeness: ${review.scores.completeness} | Testability: ${review.scores.testability}',
                              style: pw.TextStyle(
                                  fontSize: 8.5, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (review?.issues.isNotEmpty ?? false) ...[
                      pw.SizedBox(height: 6),
                      pw.Text('Detected Issues:',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: failedColor)),
                      ...review!.issues.map(
                        (issue) => pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 8, top: 2),
                          child: pw.Text(
                            '- [${issue.severity.label.toUpperCase()}] ${sanitizeText(issue.type)}: ${sanitizeText(issue.description)}',
                            style: pw.TextStyle(fontSize: 8.5, color: textDark),
                          ),
                        ),
                      ),
                    ],

                    if (review?.suggestedRevision != null &&
                        review!.suggestedRevision!.isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      pw.Text('Suggested Revision:',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor)),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 8, top: 2),
                        child: pw.Text(
                          sanitizeText(review.suggestedRevision!),
                          style: pw.TextStyle(
                              fontSize: 8.5,
                              fontStyle: pw.FontStyle.italic,
                              color: textDark),
                        ),
                      ),
                    ],

                    if (req.comments.isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      pw.Text('Reviewer Comments (${req.comments.length}):',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: textDark)),
                      ...req.comments.map(
                        (c) => pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 8, top: 2),
                          child: pw.Text(
                            '- ${sanitizeText(c.author)}: "${sanitizeText(c.text)}"',
                            style: pw.TextStyle(fontSize: 8.5, color: textMuted),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
