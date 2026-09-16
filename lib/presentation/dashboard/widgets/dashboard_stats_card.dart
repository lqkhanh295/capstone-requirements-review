import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  IconData get statusIcon {
    switch (status) {
      case ReviewStatus.passed:
        return LucideIcons.checkCircle2;
      case ReviewStatus.needsReview:
        return LucideIcons.alertTriangle;
      case ReviewStatus.failed:
        return LucideIcons.xCircle;
      case ReviewStatus.notReviewed:
        return LucideIcons.helpCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon & Status Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space8,
                    vertical: AppTheme.space4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space12),

            // Middle: Count
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppTheme.space4),

            // Label
            Text(
              status.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.space12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage > 0 ? (percentage / 100).clamp(0.0, 1.0) : 0.0,
                backgroundColor: AppTheme.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
