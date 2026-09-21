import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';

class QualityScoreCard extends StatelessWidget {
  final int overallScore;
  final Map<String, double> averageMetricScores;

  const QualityScoreCard({
    super.key,
    required this.overallScore,
    required this.averageMetricScores,
  });

  Color get scoreColor {
    if (overallScore >= 80) return AppTheme.statusPassed;
    if (overallScore >= 60) return AppTheme.statusNeedsReview;
    return AppTheme.statusFailed;
  }

  String get scoreGrade {
    if (overallScore >= 90) return 'Excellent Quality';
    if (overallScore >= 80) return 'Good Quality';
    if (overallScore >= 60) return 'Needs Revision';
    if (overallScore > 0) return 'Poor Quality';
    return 'Not Evaluated';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.award, color: AppTheme.primary, size: 16),
                  SizedBox(width: AppTheme.space8),
                  Text(
                    'Overall Quality Score',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  scoreGrade,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),

          // Main Score Content Area
          Row(
            children: [
              // Clean Score Card Box
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  color: scoreColor.withValues(alpha: 0.08),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.25)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$overallScore',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: scoreColor,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '/ 100',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space20),

              // Metrics breakdown list
              Expanded(
                child: Column(
                  children: averageMetricScores.entries.map((entry) {
                    final metricName = entry.key;
                    final scoreVal = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                metricName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${scoreVal.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: (scoreVal / 100).clamp(0.0, 1.0),
                              backgroundColor: AppTheme.surfaceSubtle,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                scoreVal >= 80
                                    ? AppTheme.statusPassed
                                    : scoreVal >= 60
                                        ? AppTheme.statusNeedsReview
                                        : AppTheme.statusFailed,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
