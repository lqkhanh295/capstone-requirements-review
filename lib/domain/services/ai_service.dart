import '../models/models.dart';

enum AIProviderType {
  mock,
  gemini,
  openai;

  String get label {
    switch (this) {
      case AIProviderType.mock:
        return 'Offline Rule Engine (Mock)';
      case AIProviderType.gemini:
        return 'Google Gemini AI';
      case AIProviderType.openai:
        return 'OpenAI GPT';
    }
  }

  String get defaultModel {
    switch (this) {
      case AIProviderType.mock:
        return 'rule-based-v1';
      case AIProviderType.gemini:
        return 'gemini-1.5-flash';
      case AIProviderType.openai:
        return 'gpt-4o-mini';
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

  /// Review a single requirement against quality criteria.
  /// [allRequirements] is optional, used for duplication & consistency cross-checking.
  Future<RequirementReview> reviewRequirement(
    Requirement requirement, {
    List<Requirement>? allRequirements,
  });

  /// Batch review all requirements with progress notification.
  Future<List<RequirementReview>> batchReviewRequirements(
    List<Requirement> requirements, {
    void Function(int completed, int total)? onProgress,
    bool Function()? shouldCancel,
  });

  /// Verify API key and network connectivity.
  Future<bool> testConnection();
}
