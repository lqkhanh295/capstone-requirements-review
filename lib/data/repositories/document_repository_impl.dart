import 'dart:typed_data';
import '../../core/errors/exceptions.dart';
import '../../core/utils/file_validator.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/document_repository.dart';
import '../../infrastructure/parsers/composite_document_parser.dart';

class DocumentRepositoryImpl implements IDocumentRepository {
  final CompositeDocumentParser _parser;

  DocumentRepositoryImpl({CompositeDocumentParser? parser})
      : _parser = parser ?? CompositeDocumentParser();

  @override
  Future<Document> loadDocument(String filePath) async {
    // 1. Validation (FR-003)
    final validation = await FileValidator.validateFile(filePath);
    if (!validation.isValid) {
      throw ValidationException(validation.errorMessage ?? 'File không hợp lệ');
    }

    // 2. Parse & Extract (FR-004 to FR-007)
    return await _parser.parseFile(filePath);
  }

  @override
  Future<Document> loadDocumentFromBytes({
    required Uint8List bytes,
    required String fileName,
    String? filePath,
  }) async {
    return await _parser.parseBytes(
      bytes: bytes,
      fileName: fileName,
      filePath: filePath,
      fileSize: bytes.length,
    );
  }

  @override
  Future<void> saveDocument(Document document) async {
    // In-memory or cache placeholder for subsequent members
  }
}
