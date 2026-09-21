import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_requirements_review/domain/services/ai_service.dart';
import 'package:capstone_requirements_review/infrastructure/ai/ai_service_factory.dart';
import 'package:capstone_requirements_review/infrastructure/ai/gemini_ai_service.dart';
import 'package:capstone_requirements_review/infrastructure/ai/mock_ai_service.dart';
import 'package:capstone_requirements_review/infrastructure/ai/ollama_ai_service.dart';
import 'package:capstone_requirements_review/infrastructure/ai/openai_ai_service.dart';

void main() {
  group('AIServiceFactory Tests', () {
    test('creates MockAIService when config provider is mock', () {
      const config = AIServiceConfig(provider: AIProviderType.mock);
      final service = AIServiceFactory.create(config);
      expect(service, isA<MockAIService>());
    });

    test('creates GeminiAIService when config provider is gemini', () {
      const config = AIServiceConfig(provider: AIProviderType.gemini, apiKey: 'dummy');
      final service = AIServiceFactory.create(config);
      expect(service, isA<GeminiAIService>());
    });

    test('creates OpenAIAIService when config provider is openai', () {
      const config = AIServiceConfig(provider: AIProviderType.openai, apiKey: 'dummy');
      final service = AIServiceFactory.create(config);
      expect(service, isA<OpenAIAIService>());
    });

    test('creates OllamaAIService when config provider is ollama', () {
      const config = AIServiceConfig(provider: AIProviderType.ollama);
      final service = AIServiceFactory.create(config);
      expect(service, isA<OllamaAIService>());
    });
  });
}
