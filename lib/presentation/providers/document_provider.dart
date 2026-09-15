import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/document_repository.dart';
import 'document_state.dart';

// Repository Provider
final documentRepositoryProvider = Provider<IDocumentRepository>((ref) {
  return DocumentRepositoryImpl();
});

// Document Notifier Provider
final documentProvider = NotifierProvider<DocumentNotifier, DocumentState>(DocumentNotifier.new);

class DocumentNotifier extends Notifier<DocumentState> {
  IDocumentRepository get _repository => ref.read(documentRepositoryProvider);

  @override
  DocumentState build() {
    return const DocumentState();
  }

  /// Load document from file path (File Picker)
  Future<void> loadFromFile(String filePath) async {
    state = state.copyWith(
      status: DocumentStatus.loading,
      loadingMessage: 'Đang đọc và phân tích tài liệu...',
      clearError: true,
    );

    try {
      final doc = await _repository.loadDocument(filePath);
      state = state.copyWith(
        status: DocumentStatus.loaded,
        document: doc,
        selectedRequirement: doc.requirements.isNotEmpty ? doc.requirements.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        status: DocumentStatus.error,
        errorMessage: e.toString().replaceFirst('ValidationException: ', '').replaceFirst('DocumentParseException: ', ''),
      );
    }
  }

  /// Load document from raw bytes (Drag & drop)
  Future<void> loadFromBytes(
    Uint8List bytes,
    String fileName, {
    String? filePath,
  }) async {
    state = state.copyWith(
      status: DocumentStatus.loading,
      loadingMessage: 'Đang xử lý tệp kéo thả: $fileName...',
      clearError: true,
    );

    try {
      final doc = await _repository.loadDocumentFromBytes(
        bytes: bytes,
        fileName: fileName,
        filePath: filePath,
      );
      state = state.copyWith(
        status: DocumentStatus.loaded,
        document: doc,
        selectedRequirement: doc.requirements.isNotEmpty ? doc.requirements.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        status: DocumentStatus.error,
        errorMessage: e.toString().replaceFirst('ValidationException: ', '').replaceFirst('DocumentParseException: ', ''),
      );
    }
  }

  /// Select a requirement
  void selectRequirement(Requirement? requirement) {
    state = state.copyWith(selectedRequirement: requirement);
  }

  /// Update review status of a requirement
  void updateRequirementStatus(String reqId, ReviewStatus newStatus) {
    if (state.document == null) return;

    final updatedList = state.document!.requirements.map((req) {
      if (req.id == reqId) {
        return req.copyWith(status: newStatus);
      }
      return req;
    }).toList();

    final updatedDoc = state.document!.copyWith(requirements: updatedList);
    final updatedSelected = state.selectedRequirement?.id == reqId
        ? state.selectedRequirement!.copyWith(status: newStatus)
        : state.selectedRequirement;

    state = state.copyWith(
      document: updatedDoc,
      selectedRequirement: updatedSelected,
    );
  }

  /// Reset to idle
  void reset() {
    state = const DocumentState();
  }
}
