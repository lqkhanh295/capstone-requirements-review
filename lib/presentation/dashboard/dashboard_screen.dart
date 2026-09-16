import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/models.dart';
import '../../domain/services/dashboard_service.dart';
import '../export/export_report_dialog.dart';
import 'widgets/dashboard_stats_card.dart';
import 'widgets/quality_score_card.dart';
import 'widgets/recent_issues_list.dart';

class DashboardScreen extends StatelessWidget {
  final Document document;
  final Function(String requirementId)? onNavigateToRequirement;

  const DashboardScreen({
    super.key,
    required this.document,
    this.onNavigateToRequirement,
  });

  @override
  Widget build(BuildContext context) {
    final summary = DashboardService.calculateSummary(document);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Document Info & Export Action
            Container(
              padding: const EdgeInsets.all(AppTheme.space20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.space12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: const Icon(
                          LucideIcons.fileText,
                          color: AppTheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                document.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: AppTheme.space8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.borderLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  document.fileType.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.calendar,
                                  size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Reviewed on ${dateFormat.format(document.importedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(width: AppTheme.space16),
                              const Icon(LucideIcons.layers,
                                  size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${document.requirements.length} Requirements',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Export Action Button
                  ElevatedButton.icon(
                    onPressed: () => ExportReportDialog.show(context, document),
                    icon: const Icon(LucideIcons.download, size: 18),
                    label: const Text('Export Report (Ctrl+E)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space20,
                        vertical: AppTheme.space16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.space24),

            // Section: Status Summary Cards (Passed, Needs Review, Failed, Not Reviewed)
            const Text(
              'Requirements Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.space12),

            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - (3 * AppTheme.space16)) / 4;

                return Row(
                  children: [
                    SizedBox(
                      width: cardWidth,
                      height: 140,
                      child: DashboardStatsCard(
                        status: ReviewStatus.passed,
                        count: summary.passedCount,
                        percentage: summary.passedPercentage,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    SizedBox(
                      width: cardWidth,
                      height: 140,
                      child: DashboardStatsCard(
                        status: ReviewStatus.needsReview,
                        count: summary.needsReviewCount,
                        percentage: summary.needsReviewPercentage,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    SizedBox(
                      width: cardWidth,
                      height: 140,
                      child: DashboardStatsCard(
                        status: ReviewStatus.failed,
                        count: summary.failedCount,
                        percentage: summary.failedPercentage,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    SizedBox(
                      width: cardWidth,
                      height: 140,
                      child: DashboardStatsCard(
                        status: ReviewStatus.notReviewed,
                        count: summary.notReviewedCount,
                        percentage: summary.notReviewedPercentage,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppTheme.space24),

            // Main Grid: Quality Score & Recent Issues
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quality Score Column
                Expanded(
                  flex: 5,
                  child: QualityScoreCard(
                    overallScore: summary.overallQualityScore,
                    averageMetricScores: summary.averageMetricScores,
                  ),
                ),
                const SizedBox(width: AppTheme.space20),

                // Recent Issues Column
                Expanded(
                  flex: 6,
                  child: RecentIssuesList(
                    issues: summary.recentIssues,
                    onSelectRequirement: onNavigateToRequirement,
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
