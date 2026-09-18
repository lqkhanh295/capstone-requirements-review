import '../../domain/services/ai_service.dart';
import 'gemini_ai_service.dart';
import 'mock_ai_service.dart';
import 'openai_ai_service.dart';

class AIServiceFactory {
  static AIService create(AIServiceConfig config) {
    switch (config.provider) {
      case AIProviderType.gemini:
        return GeminiAIService(config: config);
      case AIProviderType.openai:
        return OpenAIAIService(config: config);
      case AIProviderType.mock:
        return MockAIService();
    }
  }
}
