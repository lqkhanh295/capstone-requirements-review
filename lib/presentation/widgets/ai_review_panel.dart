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
      width: 380,
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
            _buildBatchProgressBar(context, ref, aiReviewState),

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

  Widget _buildPanelHeader(
    BuildContext context,
    WidgetRef ref,
    AIServiceConfig aiConfig,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Text(
            'AUTOMATED REVIEW',
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          // Provider Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              aiConfig.provider.name.toUpperCase(),
              style: AppTheme.mono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space8),
          // Settings button
          IconButton(
            tooltip: 'Cài đặt AI Provider',
            icon: const Icon(
              LucideIcons.settings,
              size: 15,
              color: AppTheme.textSecondary,
            ),
            onPressed: () => AISettingsDialog.show(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            splashRadius: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, WidgetRef ref, String error) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceSubtle,
        border: Border(bottom: BorderSide(color: AppTheme.statusFailed)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[ERR]',
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.statusFailed,
            ),
          ),
          const SizedBox(width: AppTheme.space8),
          Expanded(
            child: Text(
              error,
              style: AppTheme.sans(fontSize: 12, color: AppTheme.statusFailed),
            ),
          ),
          InkWell(
            onTap: () => ref.read(aiReviewProvider.notifier).clearMessages(),
            child: const Icon(
              LucideIcons.x,
              size: 14,
              color: AppTheme.statusFailed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchProgressBar(
    BuildContext context,
    WidgetRef ref,
    AIReviewState state,
  ) {
    final progress =
        state.batchTotal > 0 ? (state.batchCompleted / state.batchTotal) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceSubtle,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'BATCH AUDIT: ${state.batchCompleted} / ${state.batchTotal}',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    ref.read(aiReviewProvider.notifier).cancelBatchAnalysis(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 20),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '[ ABORT ]',
                  style: AppTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.statusFailed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.border,
            color: AppTheme.primary,
            minHeight: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPanelBody(
    BuildContext context,
    WidgetRef ref,
    AIReviewState aiState,
  ) {
    if (requirement == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NO REQUIREMENT SELECTED',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                'Select a specification from the index to inspect its automated quality audit.',
                textAlign: TextAlign.center,
                style: AppTheme.sans(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
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
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              'AUDITING ${requirement!.id}',
              style: AppTheme.mono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Evaluating 7 IEEE-830 quality dimensions...',
              style: AppTheme.sans(fontSize: 12, color: AppTheme.textSecondary),
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
              Text(
                'AUDIT PENDING: ${requirement!.id}',
                style: AppTheme.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                'No automated review has been recorded for this item yet.',
                textAlign: TextAlign.center,
                style: AppTheme.sans(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppTheme.space20),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(aiReviewProvider.notifier)
                      .analyzeRequirement(requirement!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textPrimary,
                  foregroundColor: AppTheme.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  '[ Review requirement ]',
                  style: AppTheme.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Has Review Result
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Overall Score Section
          _buildOverallScoreSection(review),

          const Divider(height: 1, color: AppTheme.border),

          // 2. Technical Audit Grid (7 Quality Dimensions)
          _buildQualityDimensionsSection(review.scores),

          const Divider(height: 1, color: AppTheme.border),

          // 3. Issues Found Section
          _buildIssuesSection(review.issues),

          // 4. Suggested Revision Section
          if (review.suggestedRevision != null &&
              review.suggestedRevision!.isNotEmpty) ...[
            const Divider(height: 1, color: AppTheme.border),
            _buildSuggestedRevisionSection(
              context,
              ref,
              review.suggestedRevision!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallScoreSection(RequirementReview review) {
    Color scoreColor;
    String scoreGrade;
    if (review.overallScore >= 80) {
      scoreColor = AppTheme.statusPassed;
      scoreGrade = 'PASS';
    } else if (review.overallScore >= 50) {
      scoreColor = AppTheme.statusNeedsReview;
      scoreGrade = 'WARN';
    } else {
      scoreColor = AppTheme.statusFailed;
      scoreGrade = 'FAIL';
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      color: AppTheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AUDIT SCORE',
                style: AppTheme.mono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${review.overallScore}',
                    style: AppTheme.mono(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    ' / 100',
                    style: AppTheme.mono(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      scoreGrade,
                      style: AppTheme.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scoreColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${review.issues.length} issues detected',
                style: AppTheme.mono(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityDimensionsSection(QualityScores scores) {
    final dimensions = [
      ('CLARITY', scores.clarity),
      ('COMPLETENESS', scores.completeness),
      ('TESTABILITY', scores.testability),
      ('CONSISTENCY', scores.consistency),
      ('FEASIBILITY', scores.feasibility),
      ('AMBIGUITY', scores.ambiguity),
      ('DUPLICATION', scores.duplication),
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUALITY AUDIT GRID',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'IEEE-830',
                style: AppTheme.mono(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          // Technical Audit Grid Table
          Table(
            columnWidths: const {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'CRITERION',
                      style: AppTheme.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'SCORE',
                      textAlign: TextAlign.center,
                      style: AppTheme.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'STATUS',
                      textAlign: TextAlign.right,
                      style: AppTheme.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              for (final d in dimensions) _buildAuditGridRow(d.$1, d.$2),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildAuditGridRow(String name, int score) {
    Color statusColor;
    String statusLabel;
    if (score >= 80) {
      statusColor = AppTheme.statusPassed;
      statusLabel = 'PASS';
    } else if (score >= 50) {
      statusColor = AppTheme.statusNeedsReview;
      statusLabel = 'WARN';
    } else {
      statusColor = AppTheme.statusFailed;
      statusLabel = 'FAIL';
    }

    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Text(
            name,
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Text(
            '$score',
            textAlign: TextAlign.center,
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                statusLabel,
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIssuesSection(List<ReviewIssue> issues) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ISSUES DETECTED',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: AppTheme.space8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: issues.isEmpty
                      ? AppTheme.surfaceSubtle
                      : AppTheme.statusFailed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(
                    color: issues.isEmpty
                        ? AppTheme.border
                        : AppTheme.statusFailed.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${issues.length}',
                  style: AppTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: issues.isEmpty
                        ? AppTheme.textMuted
                        : AppTheme.statusFailed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          if (issues.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.check,
                    size: 14,
                    color: AppTheme.statusPassed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No specification issues detected.',
                    style: AppTheme.sans(
                      fontSize: 12,
                      color: AppTheme.statusPassed,
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
              separatorBuilder: (context, index) =>
                  const Divider(height: 12, color: AppTheme.borderLight),
              itemBuilder: (context, index) {
                final issue = issues[index];
                Color sevColor;
                String sevTag;
                switch (issue.severity) {
                  case IssueSeverity.high:
                    sevColor = AppTheme.statusFailed;
                    sevTag = 'HIGH';
                    break;
                  case IssueSeverity.medium:
                    sevColor = AppTheme.statusNeedsReview;
                    sevTag = 'MED';
                    break;
                  case IssueSeverity.low:
                    sevColor = AppTheme.severityLow;
                    sevTag = 'LOW';
                    break;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '[$sevTag]',
                          style: AppTheme.mono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: sevColor,
                          ),
                        ),
                        const SizedBox(width: AppTheme.space8),
                        Expanded(
                          child: Text(
                            issue.type,
                            style: AppTheme.sans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.description,
                      style: AppTheme.sans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestedRevisionSection(
    BuildContext context,
    WidgetRef ref,
    String suggestedText,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PROPOSED REVISION',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  LucideIcons.copy,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                tooltip: 'Copy to clipboard',
                splashRadius: 14,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: suggestedText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied revision to clipboard'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(AppTheme.space12),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceSubtle,
              border: Border(
                left: BorderSide(color: AppTheme.primary, width: 2),
              ),
            ),
            child: Text(
              suggestedText,
              style: AppTheme.sans(
                fontSize: 12,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () =>
                  _confirmApplySuggestion(context, ref, suggestedText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textPrimary,
                foregroundColor: AppTheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
                elevation: 0,
              ),
              child: Text(
                '[ Apply revision ]',
                style: AppTheme.mono(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmApplySuggestion(
    BuildContext context,
    WidgetRef ref,
    String suggestedText,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusDialog),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: Text(
          'APPLY PROPOSED REVISION',
          style: AppTheme.mono(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Replace the current requirement description with the proposed revision?',
              style: AppTheme.sans(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceSubtle,
                border: Border(
                  left: BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
              child: Text(
                suggestedText,
                style: AppTheme.sans(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'CANCEL',
              style: AppTheme.mono(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (requirement != null) {
                ref
                    .read(aiReviewProvider.notifier)
                    .applySuggestedRevision(requirement!.id, suggestedText);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              ),
            ),
            child: Text(
              'APPLY',
              style: AppTheme.mono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  (!hasDoc || aiState.isAnalyzing || aiState.isBatchAnalyzing)
                      ? null
                      : () {
                          ref
                              .read(aiReviewProvider.notifier)
                              .analyzeAllRequirements();
                        },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                '[ Batch review ($reqCount) ]',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: (!hasDoc ||
                          aiState.isAnalyzing ||
                          aiState.isBatchAnalyzing)
                      ? AppTheme.textMuted
                      : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space8),
          Expanded(
            child: ElevatedButton(
              onPressed: (requirement == null ||
                      aiState.isAnalyzing ||
                      aiState.isBatchAnalyzing)
                  ? null
                  : () {
                      ref
                          .read(aiReviewProvider.notifier)
                          .analyzeRequirement(requirement!);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textPrimary,
                foregroundColor: AppTheme.surface,
                disabledBackgroundColor: AppTheme.surfaceSubtle,
                disabledForegroundColor: AppTheme.textMuted,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                '[ Review ]',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
