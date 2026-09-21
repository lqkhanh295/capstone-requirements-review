import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/models/models.dart';
import 'document_parser.dart';
import 'docx_parser.dart';
import 'pdf_parser.dart';
import 'requirement_extractor.dart';
import 'section_detector.dart';
import 'text_parser.dart';

class CompositeDocumentParser {
  final PdfContentParser _pdfParser;
  final DocxContentParser _docxParser;
  final TextContentParser _textParser;
  final Uuid _uuid;

  CompositeDocumentParser({
    PdfContentParser? pdfParser,
    DocxContentParser? docxParser,
    TextContentParser? textParser,
    Uuid? uuid,
  })  : _pdfParser = pdfParser ?? PdfContentParser(),
        _docxParser = docxParser ?? DocxContentParser(),
        _textParser = textParser ?? TextContentParser(),
        _uuid = uuid ?? const Uuid();

  /// Parses a document from a local file path
  Future<Document> parseFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw DocumentParseException('File không tồn tại: $filePath');
    }

    final bytes = await file.readAsBytes();
    final fileName = p.basename(filePath);
    final fileSize = bytes.length;

    return parseBytes(
      bytes: bytes,
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
    );
  }

  /// Parses a document from raw bytes (supports drag-and-drop & in-memory files)
  Future<Document> parseBytes({
    required Uint8List bytes,
    required String fileName,
    String? filePath,
    int? fileSize,
  }) async {
    final extension = p.extension(fileName).replaceFirst('.', '').toLowerCase();

    if (!AppConstants.supportedExtensions.contains(extension)) {
      throw DocumentParseException(
        'Định dạng .$extension không được hỗ trợ. Các định dạng hợp lệ: ${AppConstants.supportedExtensions.join(', ')}',
      );
    }

    // 1. Extract raw content based on extension
    RawDocumentContent rawContent;
    switch (extension) {
      case 'pdf':
        rawContent = await _pdfParser.extract(bytes, fileName: fileName);
        break;
      case 'docx':
        rawContent = await _docxParser.extract(bytes, fileName: fileName);
        break;
      case 'txt':
      case 'md':
        rawContent = await _textParser.extract(bytes, fileName: fileName);
        break;
      default:
        throw DocumentParseException('Không có parser phù hợp cho .$extension');
    }

    // 2. Break down into lines and detect sections
    final lines = rawContent.fullText.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final detectedSections = SectionDetector.detectSections(lines);

    // 3. Extract individual requirements with preserved / auto-generated IDs
    final requirements = RequirementExtractor.extract(
      sections: detectedSections,
      sourceName: fileName,
    );

    // 4. Build Document domain model
    return Document(
      id: _uuid.v4(),
      name: fileName,
      filePath: filePath ?? fileName,
      fileType: extension.toUpperCase(),
      fileSize: fileSize ?? bytes.length,
      importedAt: DateTime.now(),
      requirements: requirements,
      rawContent: rawContent.fullText,
      rawLines: lines,
    );
  }
}
