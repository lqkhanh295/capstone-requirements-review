import '../models/models.dart';

enum AIProviderType {
  mock,
  gemini,
  openai,
  ollama;

  String get name {
    switch (this) {
      case AIProviderType.mock:
        return 'mock';
      case AIProviderType.gemini:
        return 'gemini';
      case AIProviderType.openai:
        return 'openai';
      case AIProviderType.ollama:
        return 'ollama';
    }
  }

  String get label {
    switch (this) {
      case AIProviderType.mock:
        return 'Offline Rule Engine (Mock)';
      case AIProviderType.gemini:
        return 'Google Gemini AI';
      case AIProviderType.openai:
        return 'OpenAI GPT';
      case AIProviderType.ollama:
        return 'Ollama (Local LLM)';
    }
  }

  String get defaultModel {
    switch (this) {
      case AIProviderType.mock:
        return 'rule-based-v1';
      case AIProviderType.gemini:
        return 'gemini-3.5-flash-lite';
      case AIProviderType.openai:
        return 'gpt-4o-mini';
      case AIProviderType.ollama:
        return 'qwen2.5-coder:3b';
    }
  }
}

class AIServiceConfig {
  final AIProviderType provider;
  final String apiKey;
  final String model;
  final String? baseUrl;
  final double temperature;
  final int maxRetries;

  const AIServiceConfig({
    this.provider = AIProviderType.mock,
    this.apiKey = '',
    this.model = '',
    this.baseUrl,
    this.temperature = 0.2,
    this.maxRetries = 2,
  });

  String get effectiveModel => model.isNotEmpty ? model : provider.defaultModel;

  String get effectiveBaseUrl {
    if (baseUrl != null && baseUrl!.trim().isNotEmpty) {
      return baseUrl!.trim();
    }
    if (provider == AIProviderType.ollama) {
      return 'http://127.0.0.1:11434';
    }
    if (provider == AIProviderType.openai) {
      return 'https://api.openai.com/v1';
    }
    return '';
  }

  AIServiceConfig copyWith({
    AIProviderType? provider,
    String? apiKey,
    String? model,
    String? baseUrl,
    double? temperature,
    int? maxRetries,
  }) {
    return AIServiceConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      baseUrl: baseUrl ?? this.baseUrl,
      temperature: temperature ?? this.temperature,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }
}

abstract class AIService {
  AIProviderType get providerType;

  /// Review a single requirement against quality criteria according to active rubric.
  /// [allRequirements] is optional, used for duplication & consistency cross-checking.
  Future<RequirementReview> reviewRequirement(
    Requirement requirement, {
    List<Requirement>? allRequirements,
    Rubric? rubric,
  });

  /// Batch review all requirements with progress notification.
  Future<List<RequirementReview>> batchReviewRequirements(
    List<Requirement> requirements, {
    void Function(int completed, int total)? onProgress,
    bool Function()? shouldCancel,
    Rubric? rubric,
  });

  /// Verify API key and network connectivity.
  Future<bool> testConnection();
}
