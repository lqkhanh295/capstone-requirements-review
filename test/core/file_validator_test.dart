import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_requirements_review/core/utils/file_validator.dart';

void main() {
  group('FileValidator Tests', () {
    test('Empty path fails validation', () async {
      final result = await FileValidator.validateFile('');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('trống'));
    });

    test('Non-existent file fails validation', () async {
      final result = await FileValidator.validateFile('non_existent_file.pdf');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('không tồn tại'));
    });

    test('Unsupported file extension fails validation', () async {
      final tempFile = File('temp_test.exe');
      await tempFile.writeAsString('test');
      try {
        final result = await FileValidator.validateFile(tempFile.path);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('không được hỗ trợ'));
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    });

    test('Supported file extension succeeds validation', () async {
      final tempFile = File('temp_test.txt');
      await tempFile.writeAsString('Functional Requirements\nREQ-001: The system shall login');
      try {
        final result = await FileValidator.validateFile(tempFile.path);
        expect(result.isValid, isTrue);
        expect(result.normalizedExtension, equals('txt'));
        expect(result.fileSize, greaterThan(0));
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    });
  });
}
