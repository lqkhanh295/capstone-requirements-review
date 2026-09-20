import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/document_provider.dart';

class FileDropZone extends ConsumerStatefulWidget {
  final VoidCallback? onFileSelected;

  const FileDropZone({super.key, this.onFileSelected});

  @override
  ConsumerState<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends ConsumerState<FileDropZone> {
  bool _isDragging = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Chọn tài liệu yêu cầu (SRS)',
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final selectedPath = result.files.first.path;
        if (selectedPath != null) {
          await ref.read(documentProvider.notifier).loadFromFile(selectedPath);
          widget.onFileSelected?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi mở hộp thoại chọn file: $e'),
            backgroundColor: AppTheme.statusFailed,
          ),
        );
      }
    }
  }

  Future<void> _handleDroppedFile(DropDoneDetails details) async {
    if (details.files.isEmpty) return;
    final xFile = details.files.first;

    try {
      final bytes = await xFile.readAsBytes();
      final path = xFile.path;
      final name = xFile.name;

      if (path.isNotEmpty) {
        await ref.read(documentProvider.notifier).loadFromFile(path);
      } else {
        await ref.read(documentProvider.notifier).loadFromBytes(bytes, name);
      }
      widget.onFileSelected?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đọc file kéo thả: $e'),
            backgroundColor: AppTheme.statusFailed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentProvider);
    final isLoading = docState.isLoading;

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        _handleDroppedFile(details);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isDragging
              ? AppTheme.primarySoft
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
            color: _isDragging ? AppTheme.primary : AppTheme.border,
            width: _isDragging ? 1.5 : 1.0,
          ),
        ),
        child: InkWell(
          onTap: isLoading ? null : _pickFile,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.space32,
              horizontal: AppTheme.space24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isDragging ? LucideIcons.fileDown : LucideIcons.uploadCloud,
                  size: 28,
                  color: _isDragging ? AppTheme.primary : AppTheme.textMuted,
                ),
                const SizedBox(height: AppTheme.space16),
                Text(
                  _isDragging
                      ? 'Thả tài liệu vào đây'
                      : 'Kéo thả tài liệu vào đây hoặc nhấp để chọn tệp',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Hỗ trợ định dạng: ${AppConstants.supportedExtensions.map((e) => e.toUpperCase()).join(', ')} • Tối đa ${AppConstants.maxFileSizeReadable}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space20),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _pickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(LucideIcons.filePlus, size: 15),
                  label: const Text(
                    'Chọn tệp từ máy tính',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
