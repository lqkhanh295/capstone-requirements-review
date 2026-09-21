import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/window/window_config.dart';
import 'domain/models/models.dart';
import 'presentation/common/keyboard_shortcuts.dart';
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/export/export_report_dialog.dart';
import 'presentation/providers/ai_providers.dart';
import 'presentation/providers/document_provider.dart';
import 'presentation/providers/document_state.dart';
import 'presentation/providers/rubric_provider.dart';
import 'presentation/widgets/ai_review_panel.dart';
import 'presentation/widgets/ai_settings_dialog.dart';
import 'presentation/widgets/document_viewer_panel.dart';
import 'presentation/widgets/file_drop_zone.dart';
import 'presentation/widgets/requirement_detail_panel.dart';
import 'presentation/widgets/rubric_selector_dialog.dart';
import 'presentation/widgets/left_sidebar/requirements_list_panel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: CapstoneRequirementsApp(),
    ),
  );
}

class CapstoneRequirementsApp extends StatelessWidget {
  const CapstoneRequirementsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: WindowConfig.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTabIndex = 0; // 0 = Workspace, 1 = Dashboard
  int _centerViewMode = 0; // 0 = Detail, 1 = Document View, 2 = Split View
  bool _isGlobalDragging = false;

  Future<void> _pickNewDocument() async {
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

  Future<void> _handleGlobalDrop(DropDoneDetails details) async {
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
  void initState() {
    super.initState();
    WindowConfig.initializeWindow();
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentProvider);
    final aiConfig = ref.watch(aiConfigProvider);

    return GlobalKeyboardShortcuts(
      currentDocument: docState.document,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
            if (docState.selectedRequirement != null) {
              ref
                  .read(aiReviewProvider.notifier)
                  .analyzeRequirement(docState.selectedRequirement!);
            }
          },
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              backgroundColor: AppTheme.surface,
              elevation: 0,
              toolbarHeight: 46,
              titleSpacing: AppTheme.space16,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CAPSTONE REVIEW',
                    style: AppTheme.mono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (docState.hasDocument) ...[
                    const SizedBox(width: AppTheme.space24),
                    _buildNavTab(index: 0, label: 'Workspace'),
                    _buildNavTab(index: 1, label: 'Dashboard'),
                  ],
                ],
              ),
              actions: [
                if (docState.hasDocument) ...[
                  // Quick Export Button
                  ElevatedButton(
                    onPressed: () =>
                        ExportReportDialog.show(context, docState.document!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textPrimary,
                      foregroundColor: AppTheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '[ Export (Ctrl+E) ]',
                      style: AppTheme.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space8),
                ],
                // AI Status Pill
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () => AISettingsDialog.show(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSubtle,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Text(
                              'ENGINE: ${aiConfig.provider.name.toUpperCase()}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTheme.mono(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            LucideIcons.chevronDown,
                            size: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                if (docState.hasDocument) ...[
                  OutlinedButton(
                    onPressed: _pickNewDocument,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                      ),
                    ),
                    child: Text(
                      '[ Open document ]',
                      style: AppTheme.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space16),
                ],
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppTheme.border),
              ),
            ),
            body: DropTarget(
              onDragEntered: (_) => setState(() => _isGlobalDragging = true),
              onDragExited: (_) => setState(() => _isGlobalDragging = false),
              onDragDone: (details) {
                setState(() => _isGlobalDragging = false);
                _handleGlobalDrop(details);
              },
              child: Stack(
                children: [
                  Positioned.fill(child: _buildBody(context, docState)),
                  if (_isGlobalDragging)
                    Positioned.fill(
                      child: Container(
                        color: AppTheme.surface.withValues(alpha: 0.95),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusCard),
                              border:
                                  Border.all(color: AppTheme.primary, width: 1.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.uploadCloud,
                                  color: AppTheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'RELEASE SPECIFICATION TO IMPORT',
                                  style: AppTheme.mono(
                                    color: AppTheme.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PDF, DOCX, TXT, or Markdown',
                                  style: AppTheme.sans(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required int index,
    required String label,
  }) {
    final isSelected = _selectedTabIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTheme.mono(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DocumentState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              state.loadingMessage ?? 'PROCESSING DOCUMENT SPECIFICATIONS...',
              style: AppTheme.mono(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (!state.hasDocument) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: AppTheme.space24),
                    padding: const EdgeInsets.all(AppTheme.space12),
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      border: Border(
                        left: BorderSide(color: AppTheme.statusFailed, width: 2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '[ERR]',
                          style: AppTheme.mono(
                            color: AppTheme.statusFailed,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: AppTheme.space8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: AppTheme.sans(
                              color: AppTheme.statusFailed,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Text(
                  'CAPSTONE REQUIREMENTS AUDITOR',
                  style: AppTheme.mono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload software requirements documents (SRS) for automated extraction, IEEE-830 dimension auditing, and formal verification.',
                  style: AppTheme.sans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space24),
                const FileDropZone(),
              ],
            ),
          ),
        ),
      );
    }

    if (_selectedTabIndex == 1 && state.hasDocument) {
      return DashboardScreen(
        document: state.document!,
        onNavigateToRequirement: (reqId) {
          final found = state.document!.requirements.firstWhere(
            (r) => r.id == reqId,
            orElse: () => state.document!.requirements.first,
          );
          ref.read(documentProvider.notifier).selectRequirement(found);
          setState(() {
            _selectedTabIndex = 0;
          });
        },
      );
    }

    // Tab 0: Document loaded state with 3-column workspace layout
    final doc = state.document!;
    return Column(
      children: [
        _buildDocumentHeader(doc),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column: Requirements List
              const RequirementsListPanel(),
              // Middle Column: Requirement Detail, Document View, or Split View
              Expanded(
                child: _buildCenterContent(),
              ),
              // Right Column: AI Review Panel
              AIReviewPanel(
                requirement: state.selectedRequirement,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCenterContent() {
    switch (_centerViewMode) {
      case 1:
        return DocumentViewerPanel(
          onSwitchToDetail: () => setState(() => _centerViewMode = 0),
        );
      case 2:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: RequirementDetailPanel(
                onJumpToDocument: () => setState(() => _centerViewMode = 1),
              ),
            ),
            const VerticalDivider(width: 1, color: AppTheme.border),
            const Expanded(
              flex: 5,
              child: DocumentViewerPanel(),
            ),
          ],
        );
      case 0:
      default:
        return RequirementDetailPanel(
          onJumpToDocument: () => setState(() => _centerViewMode = 1),
        );
    }
  }

  Widget _buildDocumentHeader(Document doc) {
    final activeRubric = ref.watch(rubricProvider).activeRubric;
    String rubricShortLabel = 'RUBRIC: IEEE';
    if (activeRubric.name.contains('FPT')) {
      rubricShortLabel = 'RUBRIC: FPT CAPSTONE';
    } else if (activeRubric.name.contains('INVEST')) {
      rubricShortLabel = 'RUBRIC: INVEST';
    } else if (activeRubric.isCustom) {
      rubricShortLabel = 'RUBRIC: CUSTOM';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: 8,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'SPEC:',
              style: AppTheme.mono(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: AppTheme.space8),
            Text(
              doc.name,
              style: AppTheme.sans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: AppTheme.space8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                doc.fileType.toUpperCase(),
                style: AppTheme.mono(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space16),

            // Center View Mode Toggle
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeButton(0, LucideIcons.clipboardList, 'Đánh giá'),
                  _buildModeButton(1, LucideIcons.fileText, 'Văn bản gốc (Line View)'),
                  _buildModeButton(2, LucideIcons.columns2, 'Song song (Split)'),
                ],
              ),
            ),

            const SizedBox(width: AppTheme.space24),

            // Rubric Selector Button in Document Header
            InkWell(
              onTap: () => RubricSelectorDialog.show(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.scale, size: 12, color: AppTheme.primary),
                    const SizedBox(width: 5),
                    Text(
                      rubricShortLabel,
                      style: AppTheme.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: AppTheme.space16),
            Text(
              '${(doc.fileSize / 1024).toStringAsFixed(1)} KB',
              style: AppTheme.mono(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: AppTheme.space16),
            Text(
              '${doc.requirements.length} REQUIREMENTS',
              style: AppTheme.mono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(int mode, IconData icon, String label) {
    final isSelected = _centerViewMode == mode;
    return InkWell(
      onTap: () => setState(() => _centerViewMode = mode),
      borderRadius: BorderRadius.circular(AppTheme.radiusButton - 1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton - 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11,
              color: isSelected ? AppTheme.surface : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.mono(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.surface : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
