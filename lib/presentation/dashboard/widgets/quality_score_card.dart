import 'package:flutter/material.dart';
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
    if (overallScore >= 50) return AppTheme.statusNeedsReview;
    return AppTheme.statusFailed;
  }

  String get scoreGrade {
    if (overallScore >= 80) return 'PASS';
    if (overallScore >= 50) return 'WARN';
    if (overallScore > 0) return 'FAIL';
    return 'PENDING';
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
              Text(
                'OVERALL QUALITY SCORE',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
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
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),

          // Main Score Content Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Score Card Box
              Container(
                width: 84,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  color: AppTheme.surfaceSubtle,
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$overallScore',
                      style: AppTheme.mono(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '/ 100',
                      style: AppTheme.mono(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
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
                                metricName.toUpperCase(),
                                style: AppTheme.mono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${scoreVal.toStringAsFixed(0)}%',
                                style: AppTheme.mono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          LinearProgressIndicator(
                            value: (scoreVal / 100).clamp(0.0, 1.0),
                            backgroundColor: AppTheme.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scoreVal >= 80
                                  ? AppTheme.statusPassed
                                  : scoreVal >= 50
                                      ? AppTheme.statusNeedsReview
                                      : AppTheme.statusFailed,
                            ),
                            minHeight: 2,
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
