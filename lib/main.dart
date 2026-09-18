import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'core/theme/app_theme.dart';
import 'domain/models/models.dart';
import 'presentation/providers/ai_providers.dart';
import 'presentation/providers/document_provider.dart';
import 'presentation/providers/document_state.dart';
import 'presentation/widgets/ai_review_panel.dart';
import 'presentation/widgets/ai_settings_dialog.dart';
import 'presentation/widgets/file_drop_zone.dart';
import 'presentation/widgets/requirement_detail_panel.dart';
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
      title: 'Capstone Requirements Review',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(documentProvider);
    final aiConfig = ref.watch(aiConfigProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
          if (docState.selectedRequirement != null) {
            ref.read(aiReviewProvider.notifier).analyzeRequirement(docState.selectedRequirement!);
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
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.fileSearch, color: AppTheme.primary, size: 22),
                SizedBox(width: AppTheme.space12),
                Flexible(
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
              ],
            ),
            actions: [
              // AI Status Pill
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () => AISettingsDialog.show(context),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.sparkles, size: 14, color: AppTheme.primary),
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
                        const Icon(LucideIcons.chevronDown, size: 12, color: AppTheme.primary),
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
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
          body: _buildBody(context, ref, docState),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, DocumentState state) {
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
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.statusFailed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.alertCircle, color: AppTheme.statusFailed, size: 20),
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

    // Document loaded state with 2-panel workspace layout (List + AI Review Panel)
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
              doc.fileType,
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
                const Icon(LucideIcons.listOrdered, size: 16, color: AppTheme.textSecondary),
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
}
