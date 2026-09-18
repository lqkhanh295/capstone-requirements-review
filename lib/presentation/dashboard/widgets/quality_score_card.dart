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
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                  Icon(LucideIcons.award, color: AppTheme.primary, size: 20),
                  SizedBox(width: AppTheme.space8),
                  Text(
                    'Overall Quality Score',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space12,
                  vertical: AppTheme.space4,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(color: scoreColor.withOpacity(0.3)),
                ),
                child: Text(
                  scoreGrade,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space20),

          // Main Score Content Area
          Row(
            children: [
              // Circular Gauge / Indicator Box
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scoreColor.withOpacity(0.06),
                  border: Border.all(color: scoreColor.withOpacity(0.2), width: 3),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$overallScore',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '/ 100',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space24),

              // Metrics breakdown list
              Expanded(
                child: Column(
                  children: averageMetricScores.entries.map((entry) {
                    final metricName = entry.key;
                    final scoreVal = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.space8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                metricName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${scoreVal.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (scoreVal / 100).clamp(0.0, 1.0),
                              backgroundColor: AppTheme.borderLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                scoreVal >= 80
                                    ? AppTheme.statusPassed
                                    : scoreVal >= 60
                                        ? AppTheme.statusNeedsReview
                                        : AppTheme.statusFailed,
                              ),
                              minHeight: 6,
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
