import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

enum RequirementStatus { passed, needsReview, failed, notReviewed }

class RequirementCard extends StatelessWidget {
  final String id;
  final String title;
  final RequirementStatus status;
  final int issueCount;
  final bool isSelected;
  final VoidCallback onTap;

  const RequirementCard({
    super.key,
    required this.id,
    required this.title,
    required this.status,
    this.issueCount = 0,
    this.isSelected = false,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case RequirementStatus.passed:
        return AppTheme.statusPassed;
      case RequirementStatus.needsReview:
        return AppTheme.statusNeedsReview;
      case RequirementStatus.failed:
        return AppTheme.statusFailed;
      case RequirementStatus.notReviewed:
        return AppTheme.statusNotReviewed;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case RequirementStatus.passed:
        return LucideIcons.checkCircle;
      case RequirementStatus.needsReview:
        return LucideIcons.alertTriangle;
      case RequirementStatus.failed:
        return LucideIcons.xCircle;
      case RequirementStatus.notReviewed:
        return LucideIcons.helpCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.border.withOpacity(0.5) : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: isSelected ? AppTheme.textPrimary : AppTheme.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    id,
                    style: AppTheme.codeTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (issueCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.statusFailed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$issueCount issue${issueCount > 1 ? 's' : ''}',
                      style: AppTheme.codeTextStyle.copyWith(
                        fontSize: 10,
                        color: AppTheme.statusFailed,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
