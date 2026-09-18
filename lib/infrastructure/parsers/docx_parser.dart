import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../../core/errors/exceptions.dart';
import 'document_parser.dart';

class DocxContentParser implements IDocumentContentExtractor {
  @override
  Future<RawDocumentContent> extract(Uint8List bytes, {String? fileName}) async {
    try {
      final Archive archive = ZipDecoder().decodeBytes(bytes);
      ArchiveFile? documentXmlFile;

      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          documentXmlFile = file;
          break;
        }
      }

      if (documentXmlFile == null) {
        throw DocumentParseException('Tệp DOCX không hợp lệ: Thiếu "word/document.xml".');
      }

      final contentBytes = documentXmlFile.content as List<int>;
      final xmlString = utf8.decode(contentBytes, allowMalformed: true);
      final xmlDoc = XmlDocument.parse(xmlString);

      final List<DocumentPageOrBlock> blocks = [];
      final StringBuffer fullTextBuffer = StringBuffer();
      int blockIndex = 1;

      // Extract each paragraph <w:p>
      final paragraphs = xmlDoc.findAllElements('w:p');
      for (final p in paragraphs) {
        final textElements = p.findAllElements('w:t');
        final paragraphText = textElements.map((e) => e.innerText).join();

        if (paragraphText.trim().isNotEmpty) {
          blocks.add(DocumentPageOrBlock(
            index: blockIndex++,
            title: 'Paragraph ${blockIndex - 1}',
            text: paragraphText,
          ));
          fullTextBuffer.writeln(paragraphText);
        }
      }

      return RawDocumentContent(
        fullText: fullTextBuffer.toString(),
        blocks: blocks,
      );
    } catch (e, stack) {
      if (e is DocumentParseException) rethrow;
      throw DocumentParseException(
        'Không thể giải nén/trích xuất nội dung từ file DOCX: ${e.toString()}',
        stack,
      );
    }
  }
}
