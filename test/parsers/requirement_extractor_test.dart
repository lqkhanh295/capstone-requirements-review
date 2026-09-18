import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_requirements_review/domain/models/models.dart';
import 'package:capstone_requirements_review/infrastructure/parsers/requirement_extractor.dart';
import 'package:capstone_requirements_review/infrastructure/parsers/section_detector.dart';

void main() {
  group('RequirementExtractor Tests', () {
    test('Preserves explicit requirement IDs', () {
      final lines = [
        '# Functional Requirements',
        'REQ-001: User Registration. The system shall allow users to register an account.',
        'FR-002: Email Verification. The user shall verify their email address.',
      ];

      final sections = SectionDetector.detectSections(lines);
      final reqs = RequirementExtractor.extract(sections: sections);

      expect(reqs.length, equals(2));
      expect(reqs[0].id, equals('REQ-001'));
      expect(reqs[0].title, contains('User Registration'));
      expect(reqs[0].type, equals(RequirementType.functional));

      expect(reqs[1].id, equals('FR-002'));
      expect(reqs[1].title, contains('Email Verification'));
      expect(reqs[1].type, equals(RequirementType.functional));
    });

    test('Auto-generates REQ-001 IDs when items have no ID', () {
      final lines = [
        '# Functional Requirements',
        '- The system shall support multi-language user interface.',
        '- The system must encrypt sensitive user credentials.',
      ];

      final sections = SectionDetector.detectSections(lines);
      final reqs = RequirementExtractor.extract(sections: sections);

      expect(reqs.length, equals(2));
      expect(reqs[0].id, equals('REQ-001'));
      expect(reqs[1].id, equals('REQ-002'));
    });

    test('Parses Markdown table requirements', () {
      final lines = [
        '# Functional Requirements',
        '| ID | Title | Description |',
        '|---|---|---|',
        '| REQ-010 | Export Report | System shall export review summary to PDF and CSV |',
        '| REQ-011 | Audit Log | System shall record all reviewer actions |',
      ];

      final sections = SectionDetector.detectSections(lines);
      final reqs = RequirementExtractor.extract(sections: sections);

      expect(reqs.length, equals(2));
      expect(reqs[0].id, equals('REQ-010'));
      expect(reqs[0].title, equals('Export Report'));
      expect(reqs[1].id, equals('REQ-011'));
      expect(reqs[1].title, equals('Audit Log'));
    });
  });
}
