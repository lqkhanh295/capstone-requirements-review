import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'core/theme/app_theme.dart';
import 'core/window/window_config.dart';
import 'domain/models/models.dart';
import 'presentation/common/keyboard_shortcuts.dart';
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/export/export_report_dialog.dart';
import 'presentation/providers/ai_providers.dart';
import 'presentation/providers/document_provider.dart';
import 'presentation/providers/document_state.dart';
import 'presentation/widgets/ai_review_panel.dart';
import 'presentation/widgets/ai_settings_dialog.dart';
import 'presentation/widgets/file_drop_zone.dart';
import 'presentation/widgets/requirement_detail_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowConfig.initializeWindow();

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
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.fileSearch,
                      color: AppTheme.primary, size: 22),
                  const SizedBox(width: AppTheme.space12),
                  const Flexible(
                    child: Text(
                      'Capstone Requirements Review',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (docState.hasDocument) ...[
                    const SizedBox(width: AppTheme.space24),
                    _buildNavTab(
                      index: 0,
                      icon: LucideIcons.layoutGrid,
                      label: 'Workspace',
                    ),
                    const SizedBox(width: AppTheme.space8),
                    _buildNavTab(
                      index: 1,
                      icon: LucideIcons.barChart3,
                      label: 'Dashboard',
                    ),
                  ],
                ],
              ),
              actions: [
                if (docState.hasDocument) ...[
                  // Quick Export Button
                  ElevatedButton.icon(
                    onPressed: () =>
                        ExportReportDialog.show(context, docState.document!),
                    icon: const Icon(LucideIcons.download, size: 16),
                    label: const Text('Export (Ctrl+E)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space12,
                        vertical: AppTheme.space8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space12),
                ],
                // AI Status Pill
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () => AISettingsDialog.show(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.sparkles,
                              size: 14, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'AI: ${aiConfig.provider.label}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.chevronDown,
                              size: 12, color: AppTheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                if (docState.hasDocument) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(documentProvider.notifier).reset();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    icon: const Icon(LucideIcons.folderOpen, size: 16),
                    label: const Text('Mở tài liệu khác'),
                  ),
                  const SizedBox(width: AppTheme.space12),
                ],
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppTheme.border),
              ),
            ),
            body: _buildBody(context, docState),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTabIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space12,
          vertical: AppTheme.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
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
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: AppTheme.space16),
            Text(
              state.loadingMessage ?? 'Đang xử lý tài liệu...',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
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
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: AppTheme.space24),
                    padding: const EdgeInsets.all(AppTheme.space16),
                    decoration: BoxDecoration(
                      color: AppTheme.statusFailed.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.statusFailed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.alertCircle,
                            color: AppTheme.statusFailed, size: 20),
                        const SizedBox(width: AppTheme.space12),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.statusFailed,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Text(
                  'Nhập tài liệu yêu cầu (SRS)',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space8),
                const Text(
                  'Tải lên tài liệu phần mềm của bạn để tự động nhận diện phân đoạn và bóc tách các Requirements.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space32),
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
              SizedBox(
                width: 300,
                child: _buildRequirementsList(context, state),
              ),
              const VerticalDivider(width: 1),
              // Middle Column: Requirement Detail & Manual Review
              const Expanded(
                child: RequirementDetailPanel(),
              ),
              const VerticalDivider(width: 1),
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

  Widget _buildDocumentHeader(Document doc) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space16,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              doc.fileType.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${(doc.fileSize / 1024).toStringAsFixed(1)} KB • Đường dẫn: ${doc.filePath}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.listOrdered,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${doc.requirements.length} Requirements',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsList(BuildContext context, DocumentState state) {
    final reqs = state.document!.requirements;

    if (reqs.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy yêu cầu (Requirement) nào trong tài liệu này.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.space24),
      itemCount: reqs.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppTheme.space12),
      itemBuilder: (context, index) {
        final req = reqs[index];
        final isSelected = state.selectedRequirement?.id == req.id;

        return InkWell(
          onTap: () {
            ref.read(documentProvider.notifier).selectRequirement(req);
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.04)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.border,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        req.id,
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space8),
                    _buildTypeChip(req.type),
                    const SizedBox(width: AppTheme.space8),
                    _buildStatusBadge(req),
                    const Spacer(),
                    if (req.sourceLocation.isNotEmpty)
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 12, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            req.sourceLocation,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.space8),
                Text(
                  req.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.space4),
                Text(
                  req.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(Requirement req) {
    if (req.review != null) {
      final score = req.review!.overallScore;
      Color color;
      if (score >= 80) {
        color = AppTheme.statusPassed;
      } else if (score >= 50) {
        color = AppTheme.statusNeedsReview;
      } else {
        color = AppTheme.statusFailed;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.sparkles, size: 10, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(
              '$score/100',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      );
    }

    // Manual status
    Color statusColor;
    switch (req.status) {
      case ReviewStatus.passed:
        statusColor = AppTheme.statusPassed;
        break;
      case ReviewStatus.needsReview:
        statusColor = AppTheme.statusNeedsReview;
        break;
      case ReviewStatus.failed:
        statusColor = AppTheme.statusFailed;
        break;
      case ReviewStatus.notReviewed:
        statusColor = AppTheme.textMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        req.status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildTypeChip(RequirementType type) {
    Color bg;
    Color fg;
    switch (type) {
      case RequirementType.functional:
        bg = AppTheme.primary.withValues(alpha: 0.1);
        fg = AppTheme.primary;
        break;
      case RequirementType.nonFunctional:
        bg = AppTheme.statusNeedsReview.withValues(alpha: 0.1);
        fg = AppTheme.statusNeedsReview;
        break;
      case RequirementType.security:
        bg = AppTheme.statusFailed.withValues(alpha: 0.1);
        fg = AppTheme.statusFailed;
        break;
      case RequirementType.performance:
        bg = Colors.purple.withValues(alpha: 0.1);
        fg = Colors.purple;
        break;
      default:
        bg = AppTheme.background;
        fg = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
