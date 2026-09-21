import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';

class DashboardStatsCard extends StatelessWidget {
  final ReviewStatus status;
  final int count;
  final double percentage;
  final VoidCallback? onTap;

  const DashboardStatsCard({
    super.key,
    required this.status,
    required this.count,
    required this.percentage,
    this.onTap,
  });

  Color get statusColor {
    switch (status) {
      case ReviewStatus.passed:
        return AppTheme.statusPassed;
      case ReviewStatus.needsReview:
        return AppTheme.statusNeedsReview;
      case ReviewStatus.failed:
        return AppTheme.statusFailed;
      case ReviewStatus.notReviewed:
        return AppTheme.statusNotReviewed;
    }
  }

  String get statusTag {
    switch (status) {
      case ReviewStatus.passed:
        return 'PASSED';
      case ReviewStatus.needsReview:
        return 'NEEDS REVIEW';
      case ReviewStatus.failed:
        return 'FAILED';
      case ReviewStatus.notReviewed:
        return 'PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Status Tag & Percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusTag,
                      style: AppTheme.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppTheme.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            // Middle: Big Mono Count
            Text(
              '$count',
              style: AppTheme.mono(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.0,
              ),
            ),

            // Progress Bar
            LinearProgressIndicator(
              value: percentage > 0 ? (percentage / 100).clamp(0.0, 1.0) : 0.0,
              backgroundColor: AppTheme.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 2,
            ),
          ],
        ),
      ),
    );
  }
}
