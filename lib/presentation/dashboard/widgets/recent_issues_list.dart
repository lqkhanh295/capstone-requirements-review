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
              Row(
                children: [
                  const Icon(LucideIcons.alertTriangle,
                      color: AppTheme.statusFailed, size: 20),
                  const SizedBox(width: AppTheme.space8),
                  const Text(
                    'Recent Issues',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space8,
                      vertical: AppTheme.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${issues.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
              padding: const EdgeInsets.all(AppTheme.space32),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(LucideIcons.checkCheck,
                      size: 40, color: AppTheme.statusPassed),
                  SizedBox(height: AppTheme.space12),
                  Text(
                    'No issues detected!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.space4),
                  Text(
                    'All reviewed requirements passed without flagged issues.',
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
                height: AppTheme.space16,
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.space4, horizontal: AppTheme.space4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Severity Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.space8,
                            vertical: AppTheme.space4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            issue.severity.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.space12),

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
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'JetBrains Mono',
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
