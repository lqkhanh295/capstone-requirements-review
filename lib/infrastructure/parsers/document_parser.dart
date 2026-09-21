import 'dart:typed_data';

class RawDocumentContent {
  final String fullText;
  final List<DocumentPageOrBlock> blocks;

  const RawDocumentContent({
    required this.fullText,
    required this.blocks,
  });
}

class DocumentPageOrBlock {
  final int index; // 1-based page index or section block index
  final String title;
  final String text;

  const DocumentPageOrBlock({
    required this.index,
    required this.title,
    required this.text,
  });
}

abstract class IDocumentContentExtractor {
  Future<RawDocumentContent> extract(Uint8List bytes, {String? fileName});
}
