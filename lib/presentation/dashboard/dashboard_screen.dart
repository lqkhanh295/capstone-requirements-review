import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final dateFormat = DateFormat('yyyy-MM-dd • HH:mm');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Document Info & Export Action
            Container(
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                document.name,
                                style: AppTheme.sans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: AppTheme.space8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusPill,
                                  ),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Text(
                                  document.fileType.toUpperCase(),
                                  style: AppTheme.mono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'AUDITED: ${dateFormat.format(document.importedAt)}',
                                style: AppTheme.mono(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(width: AppTheme.space16),
                              Text(
                                'SPECIFICATIONS: ${document.requirements.length}',
                                style: AppTheme.mono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Export Action Button
                  ElevatedButton(
                    onPressed: () => ExportReportDialog.show(context, document),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textPrimary,
                      foregroundColor: AppTheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '[ Export report (Ctrl+E) ]',
                      style: AppTheme.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.space20),

            // Section: Status Summary Cards (Passed, Needs Review, Failed, Not Reviewed)
            Text(
              'REQUIREMENTS STATUS OVERVIEW',
              style: AppTheme.mono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.space12),

            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth =
                    (constraints.maxWidth - (3 * AppTheme.space16)) / 4;

                return Row(
                  children: [
                    SizedBox(
                      width: cardWidth,
                      height: 130,
                      child: DashboardStatsCard(
                        status: ReviewStatus.passed,
                        count: summary.passedCount,
                        percentage: summary.passedPercentage,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    SizedBox(
                      width: cardWidth,
                      height: 130,
                      child: DashboardStatsCard(
                        status: ReviewStatus.needsReview,
                        count: summary.needsReviewCount,
                        percentage: summary.needsReviewPercentage,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    SizedBox(
                      width: cardWidth,
                      height: 130,
                      child: DashboardStatsCard(
                        status: ReviewStatus.failed,
                        count: summary.failedCount,
                        percentage: summary.failedPercentage,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    SizedBox(
                      width: cardWidth,
                      height: 130,
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
