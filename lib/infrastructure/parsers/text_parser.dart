import 'dart:convert';
import 'dart:typed_data';
import '../../core/errors/exceptions.dart';
import 'document_parser.dart';

class TextContentParser implements IDocumentContentExtractor {
  @override
  Future<RawDocumentContent> extract(Uint8List bytes, {String? fileName}) async {
    try {
      String text;
      try {
        text = utf8.decode(bytes);
      } catch (_) {
        text = latin1.decode(bytes);
      }

      // Normalize newlines
      text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      final List<DocumentPageOrBlock> blocks = [];
      final lines = text.split('\n');

      StringBuffer currentBlock = StringBuffer();
      String currentTitle = 'Section 1';
      int blockIndex = 1;

      final headerRegex = RegExp(r'^(#{1,6}\s+.*|[A-Z0-9\.\-\s]{3,}:?$|^[0-9]+(\.[0-9]+)*\s+[A-Z].*)');

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (headerRegex.hasMatch(line.trim()) && currentBlock.length > 50) {
          blocks.add(DocumentPageOrBlock(
            index: blockIndex++,
            title: currentTitle,
            text: currentBlock.toString().trim(),
          ));
          currentBlock = StringBuffer();
          currentTitle = line.trim().replaceAll(RegExp(r'^#+\s*'), '');
        }
        currentBlock.writeln(line);
      }

      if (currentBlock.isNotEmpty) {
        blocks.add(DocumentPageOrBlock(
          index: blockIndex,
          title: currentTitle,
          text: currentBlock.toString().trim(),
        ));
      }

      return RawDocumentContent(
        fullText: text,
        blocks: blocks.isEmpty
            ? [DocumentPageOrBlock(index: 1, title: 'Content', text: text)]
            : blocks,
      );
    } catch (e, stack) {
      throw DocumentParseException(
        'Không thể đọc nội dung file văn bản: ${e.toString()}',
        stack,
      );
    }
  }
}
