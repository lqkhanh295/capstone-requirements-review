import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_theme.dart';
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
        return AppTheme.statusNotReviewed;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case ReviewStatus.passed:
        return LucideIcons.checkCircle;
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.surfaceHover
                : (_isHovering ? AppTheme.surfaceHover.withOpacity(0.5) : AppTheme.surface),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: widget.isSelected ? AppTheme.primary : AppTheme.border,
              width: 1,
            ),
            // Minimalist Left Border Highlight for selection
            boxShadow: widget.isSelected
                ? [
                    const BoxShadow(
                      color: AppTheme.primary,
                      offset: Offset(-2, 0),
                      blurRadius: 0,
                    )
                  ]
                : null,
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
                  // ID Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      widget.id,
                      style: AppTheme.codeTextStyle.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (widget.issueCount > 0)
                    // Premium Issue Badge with Dot
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.statusFailed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.issueCount} issue${widget.issueCount > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            color: AppTheme.statusFailed,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
