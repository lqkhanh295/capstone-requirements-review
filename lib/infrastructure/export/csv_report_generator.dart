import 'package:csv/csv.dart';
import '../../domain/models/models.dart';

class CSVReportGenerator {
  /// Generates a CSV string representation of the document review details.
  static String generateCSV(Document document) {
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'Requirement ID',
      'Title',
      'Description',
      'Type',
      'Status',
      'Overall AI Score',
      'Clarity',
      'Completeness',
      'Testability',
      'Consistency',
      'Feasibility',
      'Issues Count',
      'High Severity Issues',
      'Suggested Revision',
      'Comments Count',
      'Source Location',
    ]);

    // Data rows
    for (final req in document.requirements) {
      final review = req.review;
      final highIssuesCount = review?.issues
              .where((i) => i.severity == IssueSeverity.high)
              .length ??
          0;

      rows.add([
        req.id,
        req.title,
        req.description.replaceAll('\n', ' '),
        req.type.label,
        req.status.label,
        review?.overallScore ?? 'N/A',
        review?.scores.clarity ?? 'N/A',
        review?.scores.completeness ?? 'N/A',
        review?.scores.testability ?? 'N/A',
        review?.scores.consistency ?? 'N/A',
        review?.scores.feasibility ?? 'N/A',
        review?.issues.length ?? 0,
        highIssuesCount,
        review?.suggestedRevision ?? '',
        req.comments.length,
        req.sourceLocation,
      ]);
    }

    const converter = ListToCsvConverter(
      fieldDelimiter: ',',
      textDelimiter: '"',
      eol: '\r\n',
    );

    return converter.convert(rows);
  }
}
