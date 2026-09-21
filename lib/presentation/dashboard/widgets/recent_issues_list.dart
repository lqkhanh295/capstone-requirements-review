import 'package:flutter/material.dart';
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
              Text(
                'RECENT SPECIFICATION ISSUES',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '${issues.length}',
                  style: AppTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),

          // List Body
          if (issues.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No critical specification issues detected.',
                  style: AppTheme.sans(
                    fontSize: 12,
                    color: AppTheme.statusPassed,
                  ),
                ),
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
                      vertical: 4,
                      horizontal: 2,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '[${issue.severity.label.toUpperCase()}]',
                          style: AppTheme.mono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
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
                                    style: AppTheme.mono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.space8),
                                  Expanded(
                                    child: Text(
                                      issue.requirementTitle,
                                      style: AppTheme.sans(
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
                                style: AppTheme.sans(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
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
