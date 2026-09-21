import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        return AppTheme.statusNotReviewed;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
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
    final statusColor = _getStatusColor();
    final cardBg = widget.isSelected
        ? AppTheme.surfaceSubtle
        : (_isHovering ? AppTheme.surfaceHover : AppTheme.surface);
    final borderColor = _isHovering && !widget.isSelected
        ? const Color(0xFFC5CAD3)
        : AppTheme.border;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Stack(
              children: [
                // Signature 3px vertical accent bar on selected item (Rule 16)
                if (widget.isSelected)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppTheme.radiusCard),
                          bottomLeft: Radius.circular(AppTheme.radiusCard),
                        ),
                      ),
                    ),
                  ),

                // Card content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status + ID + Issue Count
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(),
                            color: statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          // ID Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceSubtle,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Text(
                              widget.id,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (widget.issueCount > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                                  '${widget.issueCount}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.statusFailed,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: widget.isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
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
        ),
      ),
    );
  }
}
