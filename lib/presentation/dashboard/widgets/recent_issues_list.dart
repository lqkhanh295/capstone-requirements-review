import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../../domain/services/dashboard_service.dart';

class RecentIssuesList extends StatelessWidget {
  final List<RequirementIssueItem> issues;
  final Function(String requirementId)? onSelectRequirement;

  const RecentIssuesList({
    super.key,
    required this.issues,
    this.onSelectRequirement,
  });

  Color severityColor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.high:
        return AppTheme.severityHigh;
      case IssueSeverity.medium:
        return AppTheme.severityMedium;
      case IssueSeverity.low:
        return AppTheme.severityLow;
    }
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
              Row(
                children: [
                  const Icon(LucideIcons.alertTriangle,
                      color: AppTheme.statusNeedsReview, size: 16),
                  const SizedBox(width: AppTheme.space8),
                  const Text(
                    'Recent Issues',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      '${issues.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),

          // List Body
          if (issues.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.space24),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(LucideIcons.checkCircle2,
                      size: 28, color: AppTheme.statusPassed),
                  SizedBox(height: 8),
                  Text(
                    'Không phát hiện vấn đề nào',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tất cả yêu cầu đã đánh giá đều đạt chuẩn chất lượng.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: issues.length > 5 ? 5 : issues.length,
              separatorBuilder: (context, index) => const Divider(
                height: AppTheme.space12,
                color: AppTheme.borderLight,
              ),
              itemBuilder: (context, index) {
                final issue = issues[index];
                final color = severityColor(issue.severity);

                return InkWell(
                  onTap: () {
                    if (onSelectRequirement != null) {
                      onSelectRequirement!(issue.requirementId);
                    }
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Severity Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(4),
                            border: Border.all(color: color.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            issue.severity.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.space8),

                        // Context & Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    issue.requirementId,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.space8),
                                  Expanded(
                                    child: Text(
                                      issue.requirementTitle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${issue.issueType}: ${issue.description}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  height: 1.35,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
