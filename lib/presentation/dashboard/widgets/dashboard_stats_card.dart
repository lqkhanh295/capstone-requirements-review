import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
            // Top Row: Icon & Percentage Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Middle: Count
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),

            // Label
            Text(
              status.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage > 0 ? (percentage / 100).clamp(0.0, 1.0) : 0.0,
                backgroundColor: AppTheme.surfaceSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
