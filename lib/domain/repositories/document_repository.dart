import 'dart:typed_data';
import '../models/models.dart';

abstract class IDocumentRepository {
  Future<Document> loadDocument(String filePath);

  Future<Document> loadDocumentFromBytes({
    required Uint8List bytes,
    required String fileName,
    String? filePath,
  });

  Future<void> saveDocument(Document document);
}
