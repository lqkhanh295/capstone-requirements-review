import '../../domain/models/models.dart';

enum DocumentStatus {
  idle,
  loading,
  loaded,
  error,
}

class DocumentState {
  final DocumentStatus status;
  final Document? document;
  final Requirement? selectedRequirement;
  final String? errorMessage;
  final String? loadingMessage;

  const DocumentState({
    this.status = DocumentStatus.idle,
    this.document,
    this.selectedRequirement,
    this.errorMessage,
    this.loadingMessage,
  });

  bool get isLoading => status == DocumentStatus.loading;
  bool get hasDocument => document != null && document!.requirements.isNotEmpty;
  int get totalRequirements => document?.requirements.length ?? 0;

  DocumentState copyWith({
    DocumentStatus? status,
    Document? document,
    Requirement? selectedRequirement,
    String? errorMessage,
    String? loadingMessage,
    bool clearSelectedRequirement = false,
    bool clearError = false,
  }) {
    return DocumentState(
      status: status ?? this.status,
      document: document ?? this.document,
      selectedRequirement: clearSelectedRequirement
          ? null
          : (selectedRequirement ?? this.selectedRequirement),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadingMessage: loadingMessage ?? this.loadingMessage,
    );
  }
}
