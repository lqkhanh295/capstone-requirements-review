import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_requirements_review/domain/models/models.dart';
import 'package:capstone_requirements_review/infrastructure/parsers/section_detector.dart';

void main() {
  group('SectionDetector Tests', () {
    test('Correctly identifies section headers', () {
      expect(SectionDetector.isSectionHeader('# 1. Functional Requirements'), isTrue);
      expect(SectionDetector.isSectionHeader('## Non-Functional Requirements'), isTrue);
      expect(SectionDetector.isSectionHeader('### Security Requirements'), isTrue);
      expect(SectionDetector.isSectionHeader('Section 4: Performance Requirements'), isTrue);
      expect(SectionDetector.isSectionHeader('This is a normal paragraph describing requirements.'), isFalse);
    });

    test('Infers correct RequirementType from section headers', () {
      expect(
        SectionDetector.inferTypeFromHeader('Functional Requirements'),
        equals(RequirementType.functional),
      );
      expect(
        SectionDetector.inferTypeFromHeader('Non-Functional Requirements'),
        equals(RequirementType.nonFunctional),
      );
      expect(
        SectionDetector.inferTypeFromHeader('Security & Access Control'),
        equals(RequirementType.security),
      );
      expect(
        SectionDetector.inferTypeFromHeader('System Performance and Latency'),
        equals(RequirementType.performance),
      );
    });

    test('Splits document lines into sections properly', () {
      final lines = [
        '# 1. Functional Requirements',
        'REQ-001: The system shall allow users to register.',
        'REQ-002: The system shall allow users to login.',
        '',
        '# 2. Non-Functional Requirements',
        'NFR-001: The system response time shall be under 200ms.',
      ];

      final sections = SectionDetector.detectSections(lines);
      expect(sections.length, equals(2));
      expect(sections[0].inferredType, equals(RequirementType.functional));
      expect(sections[1].inferredType, equals(RequirementType.nonFunctional));
    });
  });
}
