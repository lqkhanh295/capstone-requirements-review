import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:capstone_requirements_review/domain/models/models.dart';
import 'package:capstone_requirements_review/domain/services/ai_service.dart';
import 'package:capstone_requirements_review/infrastructure/ai/ollama_ai_service.dart';

void main() {
  group('OllamaAIService Tests', () {
    test('testConnection returns true when Ollama server responds 200 OK', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/tags') {
          return http.Response(
            jsonEncode({
              'models': [
                {'name': 'qwen2.5-coder:3b'},
                {'name': 'moondream:latest'}
              ]
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = OllamaAIService(
        config: const AIServiceConfig(provider: AIProviderType.ollama),
        client: mockClient,
      );

      final result = await service.testConnection();
      expect(result, isTrue);
    });

    test('testConnection throws helpful ValidationException when connection fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = OllamaAIService(
        config: const AIServiceConfig(provider: AIProviderType.ollama),
        client: mockClient,
      );

      expect(() => service.testConnection(), throwsException);
    });

    test('reviewRequirement sends format:json and parses response correctly', () async {
      const sampleAIResponse = '''
      {
        "overallScore": 92,
        "scores": {
          "clarity": 95,
          "completeness": 90,
          "testability": 90,
          "consistency": 95,
          "feasibility": 90,
          "ambiguity": 90,
          "duplication": 100
        },
        "issues": [],
        "suggestedRevision": "The system shall allow users to upload PDF documents.",
        "generalFeedback": "Requirement is clear and well specified."
      }
      ''';

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/chat') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['format'], equals('json'));
          expect(body['model'], equals('qwen2.5-coder:3b'));

          return http.Response(
            jsonEncode({
              'message': {
                'role': 'assistant',
                'content': sampleAIResponse,
              }
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = OllamaAIService(
        config: const AIServiceConfig(provider: AIProviderType.ollama),
        client: mockClient,
      );

      const requirement = Requirement(
        id: 'FR-001',
        title: 'Upload File',
        description: 'The system shall allow users to upload PDF files.',
        type: RequirementType.functional,
      );

      final review = await service.reviewRequirement(requirement);
      expect(review.overallScore, equals(92));
      expect(review.scores.clarity, equals(95));
      expect(review.suggestedRevision, contains('PDF documents'));
      expect(review.issues, isEmpty);
    });
  });
}
