import 'dart:io';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';

class FileValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? normalizedExtension;
  final int? fileSize;

  const FileValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.normalizedExtension,
    this.fileSize,
  });

  factory FileValidationResult.success({
    required String extension,
    required int fileSize,
  }) {
    return FileValidationResult._(
      isValid: true,
      normalizedExtension: extension.toLowerCase(),
      fileSize: fileSize,
    );
  }

  factory FileValidationResult.failure(String message) {
    return FileValidationResult._(
      isValid: false,
      errorMessage: message,
    );
  }
}

class FileValidator {
  /// Validates the file path according to FR-001, FR-002, FR-003.
  static Future<FileValidationResult> validateFile(String filePath) async {
    final trimmedPath = filePath.trim();
    if (trimmedPath.isEmpty) {
      return FileValidationResult.failure('Đường dẫn file không được để trống.');
    }

    final file = File(trimmedPath);

    // Check existence
    final exists = await file.exists();
    if (!exists) {
      return FileValidationResult.failure('File không tồn tại trên hệ thống: $trimmedPath');
    }

    // Check read permissions
    try {
      final raf = await file.open(mode: FileMode.read);
      await raf.close();
    } catch (e) {
      return FileValidationResult.failure('Không có quyền đọc file hoặc file đang bị khóa bởi ứng dụng khác.');
    }

    // Check extension
    final ext = p.extension(trimmedPath).replaceFirst('.', '').toLowerCase();
    if (!AppConstants.supportedExtensions.contains(ext)) {
      final supportedList = AppConstants.supportedExtensions.map((e) => e.toUpperCase()).join(', ');
      return FileValidationResult.failure(
        'Định dạng file ".$ext" không được hỗ trợ. Ứng dụng chỉ hỗ trợ: $supportedList.',
      );
    }

    // Check file size
    try {
      final length = await file.length();
      if (length <= 0) {
        return FileValidationResult.failure('File rỗng (0 bytes). Vui lòng chọn tài liệu có nội dung.');
      }
      if (length > AppConstants.maxFileSizeBytes) {
        return FileValidationResult.failure(
          'Dung lượng file (${(length / (1024 * 1024)).toStringAsFixed(1)} MB) vượt quá giới hạn cho phép (${AppConstants.maxFileSizeReadable}).',
        );
      }

      return FileValidationResult.success(
        extension: ext,
        fileSize: length,
      );
    } catch (e) {
      return FileValidationResult.failure('Không thể kiểm tra dung lượng file: ${e.toString()}');
    }
  }

  /// Synchronous extension check utility
  static bool isSupportedExtension(String filePath) {
    final ext = p.extension(filePath).replaceFirst('.', '').toLowerCase();
    return AppConstants.supportedExtensions.contains(ext);
  }
}
