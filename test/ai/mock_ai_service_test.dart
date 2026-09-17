import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_requirements_review/domain/models/models.dart';
import 'package:capstone_requirements_review/infrastructure/ai/mock_ai_service.dart';

void main() {
  group('MockAIService Tests', () {
    late MockAIService aiService;

    setUp(() {
      aiService = MockAIService();
    });

    test('Identifies ambiguity in subjective requirements', () async {
      const req = Requirement(
        id: 'REQ-001',
        title: 'Fast search',
        description: 'The system must be very fast and user friendly.',
      );

      final review = await aiService.reviewRequirement(req);

      expect(review.overallScore, lessThan(80));
      expect(review.scores.ambiguity, lessThan(80));
      expect(review.issues.any((i) => i.type == 'Ambiguity'), isTrue);
      expect(review.suggestedRevision, isNotNull);
      expect(review.suggestedRevision, contains('within 500 milliseconds'));
    });

    test('Scores well on concrete, quantifiable requirements', () async {
      const req = Requirement(
        id: 'REQ-002',
        title: 'Export Review Report',
        description: 'The system shall export the review results to a PDF file within 3 seconds under normal load.',
      );

      final review = await aiService.reviewRequirement(req);

      expect(review.overallScore, greaterThanOrEqualTo(80));
      expect(review.scores.clarity, greaterThanOrEqualTo(80));
      expect(review.scores.testability, greaterThanOrEqualTo(80));
    });

    test('Detects duplication across requirements', () async {
      const req1 = Requirement(
        id: 'REQ-001',
        title: 'User authentication with OAuth',
        description: 'The system shall allow users to log in using Google OAuth2 credentials.',
      );

      const req2 = Requirement(
        id: 'REQ-002',
        title: 'User authentication using Google OAuth',
        description: 'The system shall allow users to authenticate using Google OAuth2 credentials.',
      );

      final review = await aiService.reviewRequirement(req2, allRequirements: [req1, req2]);

      expect(review.scores.duplication, lessThan(80));
      expect(review.issues.any((i) => i.type == 'Duplication'), isTrue);
    });

    test('Batch review processes multiple requirements and reports progress', () async {
      final reqs = [
        const Requirement(id: 'REQ-001', title: 'Login', description: 'User shall login with password.'),
        const Requirement(id: 'REQ-002', title: 'Export', description: 'System shall export PDF within 2 seconds.'),
      ];

      final progressCalls = <int>[];
      final results = await aiService.batchReviewRequirements(
        reqs,
        onProgress: (completed, total) {
          progressCalls.add(completed);
        },
      );

      expect(results.length, equals(2));
      expect(progressCalls, equals([1, 2]));
    });
  });
}
