import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/models.dart';
import '../../domain/services/report_export_service.dart';

class ExportReportDialog extends StatefulWidget {
  final Document document;

  const ExportReportDialog({
    super.key,
    required this.document,
  });

  static Future<void> show(BuildContext context, Document document) async {
    return showDialog(
      context: context,
      builder: (context) => ExportReportDialog(document: document),
    );
  }

  @override
  State<ExportReportDialog> createState() => _ExportReportDialogState();
}

class _ExportReportDialogState extends State<ExportReportDialog> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  bool _isExporting = false;
  String? _statusMessage;
  bool _isSuccess = false;

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Generating report...';
      _isSuccess = false;
    });

    final result = await ReportExportService.exportDocument(
      document: widget.document,
      format: _selectedFormat,
    );

    if (!mounted) return;

    setState(() {
      _isExporting = false;
      if (result.success) {
        _isSuccess = true;
        _statusMessage =
            'Successfully exported to: ${result.filePath ?? "File saved"}';
      } else {
        _isSuccess = false;
        _statusMessage = result.errorMessage ?? 'Export cancelled or failed.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      backgroundColor: AppTheme.surface,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.fileOutput,
                        color: AppTheme.primary, size: 24),
                    SizedBox(width: AppTheme.space12),
                    Text(
                      'Export Review Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, color: AppTheme.textMuted),
                  tooltip: 'Close (Esc)',
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              'Document: ${widget.document.name} (${widget.document.requirements.length} requirements)',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.space20),

            const Text(
              'Select Export Format',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.space12),

            // Format Selection Cards
            Row(
              children: [
                // PDF Option
                Expanded(
                  child: InkWell(
                    onTap: _isExporting
                        ? null
                        : () => setState(() => _selectedFormat = ExportFormat.pdf),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.space16),
                      decoration: BoxDecoration(
                        color: _selectedFormat == ExportFormat.pdf
                            ? AppTheme.primary.withOpacity(0.06)
                            : AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: _selectedFormat == ExportFormat.pdf
                              ? AppTheme.primary
                              : AppTheme.border,
                          width: _selectedFormat == ExportFormat.pdf ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(LucideIcons.fileText,
                                  color: AppTheme.statusFailed, size: 28),
                              Radio<ExportFormat>(
                                value: ExportFormat.pdf,
                                groupValue: _selectedFormat,
                                onChanged: _isExporting
                                    ? null
                                    : (val) =>
                                        setState(() => _selectedFormat = val!),
                                activeColor: AppTheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.space8),
                          const Text(
                            'PDF Document',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Print-ready formal report with tables, cover page & AI metrics.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.space12),

                // CSV Option
                Expanded(
                  child: InkWell(
                    onTap: _isExporting
                        ? null
                        : () => setState(() => _selectedFormat = ExportFormat.csv),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.space16),
                      decoration: BoxDecoration(
                        color: _selectedFormat == ExportFormat.csv
                            ? AppTheme.primary.withOpacity(0.06)
                            : AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: _selectedFormat == ExportFormat.csv
                              ? AppTheme.primary
                              : AppTheme.border,
                          width: _selectedFormat == ExportFormat.csv ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(LucideIcons.fileSpreadsheet,
                                  color: AppTheme.statusPassed, size: 28),
                              Radio<ExportFormat>(
                                value: ExportFormat.csv,
                                groupValue: _selectedFormat,
                                onChanged: _isExporting
                                    ? null
                                    : (val) =>
                                        setState(() => _selectedFormat = val!),
                                activeColor: AppTheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.space8),
                          const Text(
                            'CSV Table Data',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Structured raw table format compatible with MS Excel.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: AppTheme.space16),
              Container(
                padding: const EdgeInsets.all(AppTheme.space12),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? AppTheme.statusPassed.withOpacity(0.1)
                      : AppTheme.statusNeedsReview.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: _isSuccess
                        ? AppTheme.statusPassed.withOpacity(0.3)
                        : AppTheme.statusNeedsReview.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess
                          ? LucideIcons.checkCircle
                          : LucideIcons.info,
                      color: _isSuccess
                          ? AppTheme.statusPassed
                          : AppTheme.statusNeedsReview,
                      size: 18,
                    ),
                    const SizedBox(width: AppTheme.space8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _isSuccess
                              ? AppTheme.statusPassed
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppTheme.space24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed:
                      _isExporting ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space16,
                      vertical: AppTheme.space12,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppTheme.space12),
                ElevatedButton.icon(
                  onPressed: _isExporting ? null : _handleExport,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(LucideIcons.download, size: 18),
                  label: Text(_isExporting
                      ? 'Exporting...'
                      : 'Export ${_selectedFormat == ExportFormat.pdf ? "PDF" : "CSV"}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space20,
                      vertical: AppTheme.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
