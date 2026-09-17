import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_requirements_review/domain/models/models.dart';
import 'package:capstone_requirements_review/infrastructure/ai/ai_prompt_helper.dart';

void main() {
  group('AIPromptHelper Tests', () {
    test('buildUserPrompt formats requirement details correctly', () {
      const req = Requirement(
        id: 'FR-001',
        title: 'Document Parser',
        description: 'The system shall parse PDF documents into text sections.',
        type: RequirementType.functional,
      );

      final prompt = AIPromptHelper.buildUserPrompt(req);

      expect(prompt, contains('ID: FR-001'));
      expect(prompt, contains('Type: Functional'));
      expect(prompt, contains('Title: Document Parser'));
      expect(prompt, contains('Description: The system shall parse PDF documents into text sections.'));
    });

    test('parseAIResponse parses valid JSON string correctly', () {
      const jsonStr = '''
      {
        "overallScore": 88,
        "scores": {
          "clarity": 90,
          "completeness": 85,
          "testability": 90,
          "consistency": 95,
          "feasibility": 90,
          "ambiguity": 85,
          "duplication": 100
        },
        "issues": [
          {
            "type": "Clarity",
            "severity": "low",
            "description": "Minor phrasing improvement possible."
          }
        ],
        "suggestedRevision": "The system shall parse PDF files within 1 second."
      }
      ''';

      final review = AIPromptHelper.parseAIResponse(jsonStr);

      expect(review.overallScore, equals(88));
      expect(review.scores.clarity, equals(90));
      expect(review.scores.duplication, equals(100));
      expect(review.issues.length, equals(1));
      expect(review.issues.first.type, equals('Clarity'));
      expect(review.suggestedRevision, equals('The system shall parse PDF files within 1 second.'));
    });

    test('parseAIResponse strips markdown fences correctly', () {
      const fencedJson = '''```json
      {
        "overallScore": 92,
        "scores": {
          "clarity": 95,
          "completeness": 90,
          "testability": 90,
          "consistency": 95,
          "feasibility": 95,
          "ambiguity": 90,
          "duplication": 90
        },
        "issues": [],
        "suggestedRevision": "Well-formatted requirement."
      }
      ```''';

      final review = AIPromptHelper.parseAIResponse(fencedJson);

      expect(review.overallScore, equals(92));
      expect(review.issues.isEmpty, isTrue);
    });
  });
}
