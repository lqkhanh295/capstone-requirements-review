import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';

class RequirementCard extends StatefulWidget {
  final String id;
  final String title;
  final ReviewStatus status;
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

  @override
  State<RequirementCard> createState() => _RequirementCardState();
}

class _RequirementCardState extends State<RequirementCard> {
  bool _isHovering = false;

  Color _getStatusColor() {
    switch (widget.status) {
      case ReviewStatus.passed:
        return AppTheme.statusPassed;
      case ReviewStatus.needsReview:
        return AppTheme.statusNeedsReview;
      case ReviewStatus.failed:
        return AppTheme.statusFailed;
      case ReviewStatus.notReviewed:
        return AppTheme.textMuted;
    }
  }

  String _getStatusLabel() {
    switch (widget.status) {
      case ReviewStatus.passed:
        return 'PASSED';
      case ReviewStatus.needsReview:
        return 'NEEDS REVIEW';
      case ReviewStatus.failed:
        return 'FAILED';
      case ReviewStatus.notReviewed:
        return 'OPEN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusLabel = _getStatusLabel();

    final itemBg = widget.isSelected
        ? AppTheme.surfaceSubtle
        : (_isHovering ? AppTheme.surfaceHover : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: itemBg,
            border: Border(
              bottom: const BorderSide(color: AppTheme.border, width: 0.8),
              left: widget.isSelected
                  ? const BorderSide(color: AppTheme.primary, width: 3.0)
                  : BorderSide.none,
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            widget.isSelected ? 13 : 16,
            12,
            16,
            12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: ID (Plex Mono) + Status indicator
              Row(
                children: [
                  Text(
                    widget.id,
                    style: AppTheme.mono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  // Subtle dot status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusLabel,
                        style: AppTheme.mono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Requirement Title (Plex Sans)
              Text(
                widget.title,
                style: AppTheme.sans(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.issueCount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '${widget.issueCount} ${widget.issueCount == 1 ? "ISSUE" : "ISSUES"}',
                  style: AppTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.statusFailed,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
