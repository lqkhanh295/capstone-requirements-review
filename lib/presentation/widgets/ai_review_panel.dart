import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/models.dart';
import '../../domain/services/ai_service.dart';
import '../providers/ai_providers.dart';
import '../providers/document_provider.dart';
import '../providers/document_state.dart';
import 'ai_settings_dialog.dart';

class AIReviewPanel extends ConsumerWidget {
  final Requirement? requirement;

  const AIReviewPanel({
    super.key,
    required this.requirement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiConfig = ref.watch(aiConfigProvider);
    final aiReviewState = ref.watch(aiReviewProvider);
    final docState = ref.watch(documentProvider);

    return Container(
      width: 360,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          left: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          _buildPanelHeader(context, ref, aiConfig),

          // Notification Messages
          if (aiReviewState.errorMessage != null)
            _buildErrorBanner(context, ref, aiReviewState.errorMessage!),

          // Batch Progress Bar (if active)
          if (aiReviewState.isBatchAnalyzing)
            _buildBatchProgressCard(context, ref, aiReviewState),

          // Main Scrollable Body
          Expanded(
            child: _buildPanelBody(context, ref, aiReviewState),
          ),

          // Bottom Action Bar (Analyze / Batch Analyze)
          _buildBottomActions(context, ref, docState, aiReviewState),
        ],
      ),
    );
  }

  Widget _buildPanelHeader(BuildContext context, WidgetRef ref, AIServiceConfig aiConfig) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space12,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, color: AppTheme.primary, size: 18),
          const SizedBox(width: AppTheme.space8),
          const Expanded(
            child: Text(
              'AI Review & Analysis',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppTheme.space8),
          // Provider Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              aiConfig.provider.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Settings button
          IconButton(
            tooltip: 'Cài đặt AI Provider',
            icon: const Icon(LucideIcons.settings, size: 16, color: AppTheme.textSecondary),
            onPressed: () => AISettingsDialog.show(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, WidgetRef ref, String error) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      margin: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.statusFailed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.statusFailed.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertCircle, color: AppTheme.statusFailed, size: 16),
          const SizedBox(width: AppTheme.space8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(fontSize: 12, color: AppTheme.statusFailed),
            ),
          ),
          InkWell(
            onTap: () => ref.read(aiReviewProvider.notifier).clearMessages(),
            child: const Icon(LucideIcons.x, size: 14, color: AppTheme.statusFailed),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchProgressCard(BuildContext context, WidgetRef ref, AIReviewState state) {
    final progress = state.batchTotal > 0 ? (state.batchCompleted / state.batchTotal) : 0.0;

    return Container(
      margin: const EdgeInsets.all(AppTheme.space12),
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppTheme.space8),
              Text(
                'Đang phân tích: ${state.batchCompleted}/${state.batchTotal}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => ref.read(aiReviewProvider.notifier).cancelBatchAnalysis(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 20),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Dừng', style: TextStyle(fontSize: 11, color: AppTheme.statusFailed)),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.border,
            color: AppTheme.primary,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelBody(BuildContext context, WidgetRef ref, AIReviewState aiState) {
    if (requirement == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.fileText, size: 36, color: AppTheme.textMuted),
              SizedBox(height: AppTheme.space12),
              Text(
                'Chọn một Requirement ở danh sách để xem đánh giá AI.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (aiState.isAnalyzing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: AppTheme.space16),
            Text(
              'AI đang đánh giá 7 tiêu chí cho ${requirement!.id}...',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    final review = requirement!.review;

    if (review == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.sparkle, size: 32, color: AppTheme.primary),
              ),
              const SizedBox(height: AppTheme.space16),
              Text(
                'Chưa có đánh giá AI cho ${requirement!.id}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.space8),
              const Text(
                'Nhấn nút bên dưới hoặc phím Ctrl + Enter để tiến hành đánh giá 7 tiêu chí chất lượng tự động.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.space16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(aiReviewProvider.notifier).analyzeRequirement(requirement!);
                },
                icon: const Icon(LucideIcons.play, size: 14),
                label: const Text('Phân tích Requirement này'),
              ),
            ],
          ),
        ),
      );
    }

    // Has Review Result
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Overall Score Card
          _buildOverallScoreCard(review),
          const SizedBox(height: AppTheme.space16),

          // 2. 7 Quality Dimensions Breakdown
          _buildQualityDimensionsCard(review.scores),
          const SizedBox(height: AppTheme.space16),

          // 3. Issues Found
          _buildIssuesCard(review.issues),
          const SizedBox(height: AppTheme.space16),

          // 4. Suggested Revision
          if (review.suggestedRevision != null && review.suggestedRevision!.isNotEmpty)
            _buildSuggestedRevisionCard(context, ref, review.suggestedRevision!),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(RequirementReview review) {
    Color scoreColor;
    String scoreGrade;
    if (review.overallScore >= 80) {
      scoreColor = AppTheme.statusPassed;
      scoreGrade = 'Đạt chuẩn (Passed)';
    } else if (review.overallScore >= 50) {
      scoreColor = AppTheme.statusNeedsReview;
      scoreGrade = 'Cần xem xét (Needs Review)';
    } else {
      scoreColor = AppTheme.statusFailed;
      scoreGrade = 'Chưa đạt (Failed)';
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withValues(alpha: 0.15),
              border: Border.all(color: scoreColor, width: 2),
            ),
            child: Center(
              child: Text(
                '${review.overallScore}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OVERALL SCORE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scoreGrade,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${review.issues.length} vấn đề được phát hiện',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityDimensionsCard(QualityScores scores) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.barChart2, size: 16, color: AppTheme.primary),
              SizedBox(width: AppTheme.space8),
              Text(
                '7 Tiêu chí chất lượng (FR-013)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          _buildCriteriaProgress('Clarity (Độ rõ ràng)', scores.clarity),
          _buildCriteriaProgress('Completeness (Đầy đủ)', scores.completeness),
          _buildCriteriaProgress('Testability (Khả năng kiểm thử)', scores.testability),
          _buildCriteriaProgress('Consistency (Tính nhất quán)', scores.consistency),
          _buildCriteriaProgress('Feasibility (Tính khả thi)', scores.feasibility),
          _buildCriteriaProgress('Ambiguity (Tính không mơ hồ)', scores.ambiguity),
          _buildCriteriaProgress('Duplication (Không trùng lặp)', scores.duplication),
        ],
      ),
    );
  }

  Widget _buildCriteriaProgress(String label, int score) {
    Color barColor;
    if (score >= 80) {
      barColor = AppTheme.statusPassed;
    } else if (score >= 50) {
      barColor = AppTheme.statusNeedsReview;
    } else {
      barColor = AppTheme.statusFailed;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text(
                '$score/100',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppTheme.background,
              color: barColor,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesCard(List<ReviewIssue> issues) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.alertTriangle, size: 16, color: AppTheme.statusNeedsReview),
              const SizedBox(width: AppTheme.space8),
              const Text(
                'Danh sách vấn đề (Issues)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: issues.isEmpty
                      ? AppTheme.statusPassed.withValues(alpha: 0.1)
                      : AppTheme.statusFailed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  '${issues.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: issues.isEmpty ? AppTheme.statusPassed : AppTheme.statusFailed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          if (issues.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.space12),
              decoration: BoxDecoration(
                color: AppTheme.statusPassed.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.check, size: 16, color: AppTheme.statusPassed),
                  SizedBox(width: AppTheme.space8),
                  Expanded(
                    child: Text(
                      'Tuyệt vời! Không phát hiện lỗi chất lượng nghiêm trọng nào.',
                      style: TextStyle(fontSize: 12, color: AppTheme.statusPassed),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: issues.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.space8),
              itemBuilder: (context, index) {
                final issue = issues[index];
                Color sevColor;
                switch (issue.severity) {
                  case IssueSeverity.high:
                    sevColor = AppTheme.statusFailed;
                    break;
                  case IssueSeverity.medium:
                    sevColor = AppTheme.statusNeedsReview;
                    break;
                  case IssueSeverity.low:
                    sevColor = Colors.blueGrey;
                    break;
                }

                return Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: sevColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              issue.severity.label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: sevColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.space8),
                          Text(
                            issue.type,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestedRevisionCard(BuildContext context, WidgetRef ref, String suggestedText) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 16, color: AppTheme.primary),
              const SizedBox(width: AppTheme.space8),
              const Text(
                'Đề xuất cải tiến (Suggested Revision)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(LucideIcons.copy, size: 14, color: AppTheme.textSecondary),
                tooltip: 'Sao chép',
                splashRadius: 16,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: suggestedText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã sao chép văn bản đề xuất vào Clipboard')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space8),
          Container(
            padding: const EdgeInsets.all(AppTheme.space12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              suggestedText,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _confirmApplySuggestion(context, ref, suggestedText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(LucideIcons.checkCheck, size: 14),
              label: const Text('Áp dụng đề xuất này', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmApplySuggestion(BuildContext context, WidgetRef ref, String suggestedText) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.helpCircle, color: AppTheme.primary, size: 20),
            SizedBox(width: 8),
            Text('Xác nhận áp dụng đề xuất', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có chắc chắn muốn thay thế mô tả hiện tại của Requirement bằng nội dung đề xuất từ AI không?',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                suggestedText,
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (requirement != null) {
                ref.read(aiReviewProvider.notifier).applySuggestedRevision(requirement!.id, suggestedText);
              }
            },
            child: const Text('Xác nhận áp dụng'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    DocumentState docState,
    AIReviewState aiState,
  ) {
    final hasDoc = docState.hasDocument;
    final reqCount = docState.document?.requirements.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (!hasDoc || aiState.isAnalyzing || aiState.isBatchAnalyzing)
                      ? null
                      : () {
                          ref.read(aiReviewProvider.notifier).analyzeAllRequirements();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(LucideIcons.layers, size: 14),
                  label: Text('Batch AI ($reqCount)', style: const TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: AppTheme.space8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (requirement == null || aiState.isAnalyzing || aiState.isBatchAnalyzing)
                      ? null
                      : () {
                          ref.read(aiReviewProvider.notifier).analyzeRequirement(requirement!);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(LucideIcons.sparkles, size: 14),
                  label: const Text('Phân tích (Ctrl+↵)', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
