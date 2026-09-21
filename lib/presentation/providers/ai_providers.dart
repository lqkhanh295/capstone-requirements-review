import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/models/models.dart';
import '../../domain/services/ai_service.dart';
import '../../infrastructure/ai/ai_service_factory.dart';
import 'document_provider.dart';

// ----------------------------------------------------
// AI Config Provider
// ----------------------------------------------------
final aiConfigProvider = NotifierProvider<AIConfigNotifier, AIServiceConfig>(AIConfigNotifier.new);

class AIConfigNotifier extends Notifier<AIServiceConfig> {
  @override
  AIServiceConfig build() {
    return const AIServiceConfig(
      provider: AIProviderType.mock,
      model: 'rule-based-v1',
    );
  }

  void updateConfig(AIServiceConfig config) {
    state = config;
  }

  void setProvider(AIProviderType provider) {
    state = state.copyWith(
      provider: provider,
      model: provider.defaultModel,
      baseUrl: provider == AIProviderType.ollama ? 'http://127.0.0.1:11434' : null,
    );
  }

  void setApiKey(String apiKey) {
    state = state.copyWith(apiKey: apiKey);
  }

  void setModel(String model) {
    state = state.copyWith(model: model);
  }

  void setBaseUrl(String? baseUrl) {
    state = state.copyWith(baseUrl: baseUrl);
  }
}

// ----------------------------------------------------
// AI Service Provider
// ----------------------------------------------------
final aiServiceProvider = Provider<AIService>((ref) {
  final config = ref.watch(aiConfigProvider);
  return AIServiceFactory.create(config);
});

// ----------------------------------------------------
// AI Review State & Notifier
// ----------------------------------------------------
class AIReviewState {
  final bool isAnalyzing;
  final bool isBatchAnalyzing;
  final int batchCompleted;
  final int batchTotal;
  final String? errorMessage;
  final String? successMessage;
  final bool isTestingConnection;
  final String? connectionStatus;
  final bool? connectionSuccess;

  const AIReviewState({
    this.isAnalyzing = false,
    this.isBatchAnalyzing = false,
    this.batchCompleted = 0,
    this.batchTotal = 0,
    this.errorMessage,
    this.successMessage,
    this.isTestingConnection = false,
    this.connectionStatus,
    this.connectionSuccess,
  });

  AIReviewState copyWith({
    bool? isAnalyzing,
    bool? isBatchAnalyzing,
    int? batchCompleted,
    int? batchTotal,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    bool? isTestingConnection,
    String? connectionStatus,
    bool? connectionSuccess,
    bool clearConnectionStatus = false,
  }) {
    return AIReviewState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isBatchAnalyzing: isBatchAnalyzing ?? this.isBatchAnalyzing,
      batchCompleted: batchCompleted ?? this.batchCompleted,
      batchTotal: batchTotal ?? this.batchTotal,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isTestingConnection: isTestingConnection ?? this.isTestingConnection,
      connectionStatus: clearConnectionStatus ? null : (connectionStatus ?? this.connectionStatus),
      connectionSuccess: clearConnectionStatus ? null : (connectionSuccess ?? this.connectionSuccess),
    );
  }
}

final aiReviewProvider = NotifierProvider<AIReviewNotifier, AIReviewState>(AIReviewNotifier.new);

class AIReviewNotifier extends Notifier<AIReviewState> {
  bool _cancelRequested = false;

  @override
  AIReviewState build() {
    return const AIReviewState();
  }

  /// Analyze the currently selected requirement
  Future<void> analyzeRequirement(Requirement requirement) async {
    final aiService = ref.read(aiServiceProvider);
    final docState = ref.read(documentProvider);
    final allReqs = docState.document?.requirements;

    state = state.copyWith(
      isAnalyzing: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final review = await aiService.reviewRequirement(
        requirement,
        allRequirements: allReqs,
      );

      // Determine recommended review status based on overall score if not manually reviewed
      ReviewStatus updatedStatus = requirement.status;
      if (requirement.status == ReviewStatus.notReviewed) {
        if (review.overallScore >= 80) {
          updatedStatus = ReviewStatus.passed;
        } else if (review.overallScore >= 50) {
          updatedStatus = ReviewStatus.needsReview;
        } else {
          updatedStatus = ReviewStatus.failed;
        }
      }

      final updatedReq = requirement.copyWith(
        review: review,
        status: updatedStatus,
      );

      // Update requirement inside documentProvider
      _updateRequirementInDocument(updatedReq);

      state = state.copyWith(
        isAnalyzing: false,
        successMessage: 'Phân tích AI cho ${requirement.id} hoàn tất (${review.overallScore}/100)',
      );
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: _extractErrorMessage(e),
      );
    }
  }

  /// Batch analyze all requirements in current document
  Future<void> analyzeAllRequirements() async {
    final docState = ref.read(documentProvider);
    if (docState.document == null || docState.document!.requirements.isEmpty) return;

    final requirements = docState.document!.requirements;
    final aiService = ref.read(aiServiceProvider);

    _cancelRequested = false;
    state = state.copyWith(
      isBatchAnalyzing: true,
      batchCompleted: 0,
      batchTotal: requirements.length,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final updatedList = <Requirement>[];

      for (int i = 0; i < requirements.length; i++) {
        if (_cancelRequested) {
          break;
        }

        final req = requirements[i];
        final review = await aiService.reviewRequirement(
          req,
          allRequirements: requirements,
        );

        ReviewStatus updatedStatus = req.status;
        if (req.status == ReviewStatus.notReviewed) {
          if (review.overallScore >= 80) {
            updatedStatus = ReviewStatus.passed;
          } else if (review.overallScore >= 50) {
            updatedStatus = ReviewStatus.needsReview;
          } else {
            updatedStatus = ReviewStatus.failed;
          }
        }

        final updatedReq = req.copyWith(
          review: review,
          status: updatedStatus,
        );
        updatedList.add(updatedReq);

        state = state.copyWith(
          batchCompleted: i + 1,
        );

        // Update single requirement in document progressively
        _updateRequirementInDocument(updatedReq);
      }

      state = state.copyWith(
        isBatchAnalyzing: false,
        successMessage: _cancelRequested
            ? 'Đã dừng phân tích hàng loạt.'
            : 'Đã hoàn tất phân tích AI cho toàn bộ ${requirements.length} yêu cầu!',
      );
    } catch (e) {
      state = state.copyWith(
        isBatchAnalyzing: false,
        errorMessage: 'Lỗi trong quá trình phân tích hàng loạt: ${_extractErrorMessage(e)}',
      );
    }
  }

  void cancelBatchAnalysis() {
    _cancelRequested = true;
    state = state.copyWith(
      isBatchAnalyzing: false,
      successMessage: 'Đã yêu cầu hủy phân tích hàng loạt.',
    );
  }

  /// Apply Suggested Revision to requirement description
  void applySuggestedRevision(String reqId, String suggestedText) {
    final docState = ref.read(documentProvider);
    if (docState.document == null) return;

    final req = docState.document!.requirements.firstWhere(
      (r) => r.id == reqId,
      orElse: () => throw Exception('Requirement $reqId không tìm thấy'),
    );

    final updatedReq = req.copyWith(
      description: suggestedText,
    );

    _updateRequirementInDocument(updatedReq);

    state = state.copyWith(
      successMessage: 'Đã áp dụng đề xuất cải tiến cho $reqId!',
    );
  }

  /// Test connectivity with current AI provider
  Future<void> testConnection() async {
    final aiService = ref.read(aiServiceProvider);
    state = state.copyWith(
      isTestingConnection: true,
      clearConnectionStatus: true,
    );

    try {
      final success = await aiService.testConnection();
      state = state.copyWith(
        isTestingConnection: false,
        connectionSuccess: success,
        connectionStatus: success ? 'Kết nối thành công!' : 'Kết nối thất bại.',
      );
    } catch (e) {
      state = state.copyWith(
        isTestingConnection: false,
        connectionSuccess: false,
        connectionStatus: _extractErrorMessage(e),
      );
    }
  }

  String _extractErrorMessage(Object e) {
    if (e is DocumentParseException) {
      return e.message;
    }
    if (e is ValidationException) {
      return e.message;
    }
    return e
        .toString()
        .replaceFirst('DocumentParseException: ', '')
        .replaceFirst('ValidationException: ', '')
        .replaceFirst('Exception: ', '');
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  void _updateRequirementInDocument(Requirement updatedReq) {
    final docNotifier = ref.read(documentProvider.notifier);
    final docState = ref.read(documentProvider);
    if (docState.document == null) return;

    final updatedList = docState.document!.requirements.map((r) {
      return r.id == updatedReq.id ? updatedReq : r;
    }).toList();

    final updatedDoc = docState.document!.copyWith(requirements: updatedList);
    final isSelected = docState.selectedRequirement?.id == updatedReq.id;

    // Use direct state mutation in notifier or update via public methods
    // Since DocumentNotifier manages document state, we can add a helper or update state:
    docNotifier.updateRequirement(updatedReq, updatedDoc, isSelected);
  }
}
