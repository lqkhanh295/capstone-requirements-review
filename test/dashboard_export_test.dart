import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_requirements_review/domain/models/models.dart';
import 'package:capstone_requirements_review/domain/services/dashboard_service.dart';
import 'package:capstone_requirements_review/domain/services/report_export_service.dart';
import 'package:capstone_requirements_review/infrastructure/export/csv_report_generator.dart';
import 'package:capstone_requirements_review/infrastructure/export/pdf_report_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardService Unit Tests', () {
    late Document testDocument;

    setUp(() {
      testDocument = Document(
        id: 'DOC-TEST-001',
        name: 'Test_Specification.pdf',
        filePath: '/test/Test_Specification.pdf',
        fileType: 'pdf',
        fileSize: 1024,
        importedAt: DateTime(2026, 9, 16, 10, 0, 0),
        requirements: [
          Requirement(
            id: 'REQ-001',
            title: 'User Authentication',
            description: 'The system shall authenticate users securely.',
            type: RequirementType.security,
            status: ReviewStatus.passed,
            review: const RequirementReview(
              overallScore: 90,
              scores: QualityScores(
                clarity: 90,
                completeness: 90,
                testability: 90,
                consistency: 90,
                feasibility: 90,
              ),
              issues: [],
            ),
          ),
          Requirement(
            id: 'REQ-002',
            title: 'Performance Response Time',
            description: 'The response time shall be quick.',
            type: RequirementType.performance,
            status: ReviewStatus.failed,
            review: const RequirementReview(
              overallScore: 50,
              scores: QualityScores(
                clarity: 40,
                completeness: 50,
                testability: 40,
                consistency: 60,
                feasibility: 60,
              ),
              issues: [
                ReviewIssue(
                  type: 'Ambiguity',
                  severity: IssueSeverity.high,
                  description: '"Quick" is vague and not quantifiable.',
                ),
              ],
            ),
          ),
          Requirement(
            id: 'REQ-003',
            title: 'Data Storage Backup',
            description: 'Backup data daily at midnight.',
            type: RequirementType.nonFunctional,
            status: ReviewStatus.needsReview,
            review: const RequirementReview(
              overallScore: 70,
              scores: QualityScores(
                clarity: 70,
                completeness: 70,
                testability: 70,
                consistency: 70,
                feasibility: 70,
              ),
              issues: [
                ReviewIssue(
                  type: 'Completeness',
                  severity: IssueSeverity.medium,
                  description: 'Specify backup storage target path.',
                ),
              ],
            ),
          ),
          const Requirement(
            id: 'REQ-004',
            title: 'Unreviewed Module',
            description: 'Description for unreviewed requirement.',
            type: RequirementType.functional,
            status: ReviewStatus.notReviewed,
          ),
        ],
      );
    });

    test('calculateSummary computes status counts accurately', () {
      final summary = DashboardService.calculateSummary(testDocument);

      expect(summary.totalRequirements, equals(4));
      expect(summary.passedCount, equals(1));
      expect(summary.failedCount, equals(1));
      expect(summary.needsReviewCount, equals(1));
      expect(summary.notReviewedCount, equals(1));
    });

    test('calculateSummary computes average overall quality score', () {
      final summary = DashboardService.calculateSummary(testDocument);

      // (90 + 50 + 70) / 3 = 70
      expect(summary.overallQualityScore, equals(70));
    });

    test('calculateSummary sorts issues by high severity first', () {
      final summary = DashboardService.calculateSummary(testDocument);

      expect(summary.recentIssues.length, equals(2));
      expect(summary.recentIssues[0].severity, equals(IssueSeverity.high));
      expect(summary.recentIssues[0].requirementId, equals('REQ-002'));
      expect(summary.recentIssues[1].severity, equals(IssueSeverity.medium));
      expect(summary.recentIssues[1].requirementId, equals('REQ-003'));
    });
  });

  group('CSV & PDF Report Generator Tests', () {
    late Document testDocument;

    setUp(() {
      testDocument = Document(
        id: 'DOC-EXPORT-001',
        name: 'Export_Test_Doc.pdf',
        filePath: '/export/doc.pdf',
        fileType: 'pdf',
        fileSize: 2048,
        importedAt: DateTime.now(),
        requirements: [
          Requirement(
            id: 'REQ-101',
            title: 'Export Feature Test',
            description: 'System shall export report to PDF and CSV.',
            type: RequirementType.functional,
            status: ReviewStatus.passed,
            review: const RequirementReview(
              overallScore: 95,
              scores: QualityScores(
                clarity: 95,
                completeness: 95,
                testability: 95,
                consistency: 95,
                feasibility: 95,
              ),
              issues: [],
              suggestedRevision: 'System shall export report to PDF and CSV.',
            ),
          ),
        ],
      );
    });

    test('CSVReportGenerator generates valid CSV content with headers', () {
      final csvString = CSVReportGenerator.generateCSV(testDocument);

      expect(csvString, contains('Requirement ID,Title,Description'));
      expect(csvString, contains('REQ-101'));
      expect(csvString, contains('Export Feature Test'));
      expect(csvString, contains('Passed'));
      expect(csvString, contains('95'));
    });

    test('PDFReportGenerator generates non-empty PDF byte data', () async {
      final pdfBytes = await PDFReportGenerator.generatePDF(testDocument);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));
      // PDF magic bytes signature: %PDF-
      expect(String.fromCharCodes(pdfBytes.take(5)), contains('%PDF-'));
    });

    test('ReportExportService isolate async helper functions work', () async {
      final csvData = await ReportExportService.generateCsvAsync(testDocument);
      expect(csvData, contains('REQ-101'));

      final pdfData = await ReportExportService.generatePdfAsync(testDocument);
      expect(pdfData.length, greaterThan(0));
    });

    test('PDFReportGenerator properly renders Unicode, Vietnamese and special characters', () async {
      final unicodeDoc = Document(
        id: 'DOC-UNICODE-001',
        name: 'Báo_Cáo_Đánh_Giá_SRS.pdf',
        filePath: '/export/doc.pdf',
        fileType: 'pdf',
        fileSize: 2048,
        importedAt: DateTime.now(),
        requirements: const [
          Requirement(
            id: 'REQ-VN-001',
            title: '│ Đăng nhập hệ thống │ Hợp lệ │',
            description: 'Người dùng có thể đăng nhập bằng email & mật khẩu – tỷ lệ 220–240 px • bảo mật cao.',
            type: RequirementType.functional,
            status: ReviewStatus.passed,
            review: RequirementReview(
              overallScore: 92,
              scores: QualityScores(
                clarity: 90,
                completeness: 95,
                testability: 90,
                consistency: 90,
                feasibility: 95,
              ),
              issues: [
                ReviewIssue(
                  type: 'Tiêu chuẩn',
                  severity: IssueSeverity.low,
                  description: 'Cần ghi rõ độ dài mật khẩu (tối thiểu 8 ký tự).',
                ),
              ],
              suggestedRevision: 'Hệ thống cần yêu cầu mật khẩu tối thiểu 8 ký tự.',
            ),
          ),
        ],
      );

      final pdfBytes = await PDFReportGenerator.generatePDF(unicodeDoc);
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));
      expect(String.fromCharCodes(pdfBytes.take(5)), contains('%PDF-'));
    });
  });
}
