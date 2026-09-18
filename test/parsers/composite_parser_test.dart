import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_requirements_review/infrastructure/parsers/composite_document_parser.dart';

void main() {
  group('CompositeDocumentParser Tests', () {
    final parser = CompositeDocumentParser();

    test('Parses markdown document correctly', () async {
      const mdContent = '''
# 1. Functional Requirements
REQ-001: File Import
The system shall allow users to upload PDF, DOCX, TXT, and Markdown files.

REQ-002: Drag and Drop
The system shall support drag and drop file upload with visual feedback.

# 2. Non-Functional Requirements
NFR-001: Performance
The system shall extract requirements from 50-page documents within 3 seconds.
''';

      final doc = await parser.parseBytes(
        bytes: Uint8List.fromList(mdContent.codeUnits),
        fileName: 'SRS_Test.md',
      );

      expect(doc.name, equals('SRS_Test.md'));
      expect(doc.fileType, equals('MD'));
      expect(doc.requirements.length, equals(3));
      expect(doc.requirements[0].id, equals('REQ-001'));
      expect(doc.requirements[1].id, equals('REQ-002'));
      expect(doc.requirements[2].id, equals('NFR-001'));
    });

    test('Parses the actual Capstone_Requirements_Review_SRS_v1.0.pdf in workspace', () async {
      final pdfFile = File('Capstone_Requirements_Review_SRS_v1.0.pdf');
      if (await pdfFile.exists()) {
        final doc = await parser.parseFile(pdfFile.path);
        expect(doc.fileType, equals('PDF'));
        expect(doc.requirements.isNotEmpty, isTrue);
        // Verify that parsed requirements have IDs
        expect(doc.requirements.any((r) => r.id.contains('REQ') || r.id.contains('FR')), isTrue);
      }
    });
  });
}
