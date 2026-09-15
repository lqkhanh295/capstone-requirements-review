import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../core/errors/exceptions.dart';
import 'document_parser.dart';

class PdfContentParser implements IDocumentContentExtractor {
  @override
  Future<RawDocumentContent> extract(Uint8List bytes, {String? fileName}) async {
    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: bytes);
      final int pageCount = document.pages.count;
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      final List<DocumentPageOrBlock> blocks = [];
      final StringBuffer fullTextBuffer = StringBuffer();

      for (int i = 0; i < pageCount; i++) {
        final String pageText = extractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );

        blocks.add(DocumentPageOrBlock(
          index: i + 1,
          title: 'Page ${i + 1}',
          text: pageText,
        ));

        fullTextBuffer.writeln(pageText);
        fullTextBuffer.writeln(); // extra newline between pages
      }

      return RawDocumentContent(
        fullText: fullTextBuffer.toString(),
        blocks: blocks,
      );
    } catch (e, stack) {
      throw DocumentParseException(
        'Không thể giải nén/trích xuất nội dung từ file PDF: ${e.toString()}',
        stack,
      );
    } finally {
      document?.dispose();
    }
  }
}
