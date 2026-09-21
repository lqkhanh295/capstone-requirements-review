import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/parsers/requirement_extractor.dart';
import '../providers/document_provider.dart';

class RequirementDetailPanel extends ConsumerStatefulWidget {
  const RequirementDetailPanel({super.key});

  @override
  ConsumerState<RequirementDetailPanel> createState() =>
      _RequirementDetailPanelState();
}

class _RequirementDetailPanelState
    extends ConsumerState<RequirementDetailPanel> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _editCommentController = TextEditingController();
  String? _editingCommentId;

  @override
  void dispose() {
    _commentController.dispose();
    _editCommentController.dispose();
    super.dispose();
  }

  void _saveReviewSession(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã lưu trạng thái phiên review hiện tại.',
          style: AppTheme.sans(fontSize: 12),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentProvider);
    final selectedReq = state.selectedRequirement;

    if (selectedReq == null) {
      return _buildEmptyState();
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
            _saveReviewSession(context),
      },
      child: Focus(
        autofocus: true,
        child: Container(
          color: AppTheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(selectedReq),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Requirement Title
                      Text(
                        selectedReq.title.toUpperCase(),
                        style: AppTheme.sans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.3,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Description
                      _buildDescription(selectedReq),
                      const SizedBox(height: 28),
                      const Divider(height: 1),
                      const SizedBox(height: 20),

                      // Metadata Grid: SOURCE & STATUS
                      _buildMetadataGrid(selectedReq),
                      const SizedBox(height: 28),
                      const Divider(height: 1),
                      const SizedBox(height: 20),

                      // Manual Review Status Selection
                      _buildManualReviewSection(selectedReq),
                      const SizedBox(height: 28),
                      const Divider(height: 1),
                      const SizedBox(height: 20),

                      // Comments / Notes
                      _buildCommentsSection(selectedReq),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppTheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NO REQUIREMENT SELECTED',
              style: AppTheme.mono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select a requirement from the list on the left to inspect details.',
              style: AppTheme.sans(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Requirement req) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 16,
      ),
      color: AppTheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Large Visual Identity: Requirement ID
          Text(
            req.id,
            style: AppTheme.mono(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            ),
            child: Text(
              req.type.label.toUpperCase(),
              style: AppTheme.mono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          // Status indicator
          _buildStatusTag(req.status),
        ],
      ),
    );
  }

  Widget _buildStatusTag(ReviewStatus status) {
    Color statusColor;
    String label;
    switch (status) {
      case ReviewStatus.passed:
        statusColor = AppTheme.statusPassed;
        label = 'PASSED';
        break;
      case ReviewStatus.needsReview:
        statusColor = AppTheme.statusNeedsReview;
        label = 'NEEDS REVIEW';
        break;
      case ReviewStatus.failed:
        statusColor = AppTheme.statusFailed;
        label = 'FAILED';
        break;
      case ReviewStatus.notReviewed:
        statusColor = AppTheme.textMuted;
        label = 'OPEN';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTheme.mono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: statusColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Requirement req) {
    final rawLines = req.description.split('\n');
    final displayText = (rawLines.length > 2)
        ? RequirementExtractor.formatDescription(rawLines)
        : (req.description.isNotEmpty ? req.description : 'Không có mô tả chi tiết.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SPECIFICATION',
          style: AppTheme.mono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            border: Border.all(color: AppTheme.border, width: 1.0),
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          child: Text(
            displayText,
            style: AppTheme.sans(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataGrid(Requirement req) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOURCE',
          style: AppTheme.mono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          req.sourceLocation.isNotEmpty ? req.sourceLocation : 'N/A',
          style: AppTheme.mono(
            fontSize: 12,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildManualReviewSection(Requirement req) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REVIEW STATUS',
          style: AppTheme.mono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ReviewStatus.values.map((status) {
            final isSelected = req.status == status;
            return _buildStatusButton(status, isSelected, req.id);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    ReviewStatus status,
    bool isSelected,
    String reqId,
  ) {
    Color activeColor;
    String label;

    switch (status) {
      case ReviewStatus.passed:
        activeColor = AppTheme.statusPassed;
        label = 'PASSED';
        break;
      case ReviewStatus.needsReview:
        activeColor = AppTheme.statusNeedsReview;
        label = 'NEEDS ATTENTION';
        break;
      case ReviewStatus.failed:
        activeColor = AppTheme.statusFailed;
        label = 'FAILED';
        break;
      case ReviewStatus.notReviewed:
        activeColor = AppTheme.textSecondary;
        label = 'OPEN';
        break;
    }

    return InkWell(
      onTap: () {
        ref
            .read(documentProvider.notifier)
            .updateRequirementStatus(reqId, status);
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : AppTheme.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: AppTheme.mono(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? activeColor : AppTheme.textPrimary,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(Requirement req) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REVIEWER NOTES',
          style: AppTheme.mono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        if (req.comments.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: req.comments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final comment = req.comments[index];
              return _buildCommentItem(req.id, comment);
            },
          ),
          const SizedBox(height: 12),
        ],
        _buildCommentInput(req.id),
      ],
    );
  }

  Widget _buildCommentItem(String reqId, ReviewComment comment) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.author.toUpperCase(),
                style: AppTheme.mono(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(comment.createdAt),
                style: AppTheme.mono(fontSize: 10, color: AppTheme.textMuted),
              ),
              const Spacer(),
              if (_editingCommentId == comment.id) ...[
                InkWell(
                  onTap: () {
                    if (_editCommentController.text.trim().isNotEmpty) {
                      final updatedComment = comment.copyWith(
                        text: _editCommentController.text.trim(),
                      );
                      ref
                          .read(documentProvider.notifier)
                          .updateComment(reqId, updatedComment);
                    }
                    setState(() {
                      _editingCommentId = null;
                    });
                  },
                  child: const Icon(
                    LucideIcons.check,
                    size: 14,
                    color: AppTheme.statusPassed,
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    setState(() {
                      _editingCommentId = null;
                    });
                  },
                  child: const Icon(
                    LucideIcons.x,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ] else ...[
                InkWell(
                  onTap: () {
                    setState(() {
                      _editingCommentId = comment.id;
                      _editCommentController.text = comment.text;
                    });
                  },
                  child: const Icon(
                    LucideIcons.pencil,
                    size: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    ref
                        .read(documentProvider.notifier)
                        .deleteComment(reqId, comment.id);
                  },
                  child: const Icon(
                    LucideIcons.trash2,
                    size: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          if (_editingCommentId == comment.id)
            TextField(
              controller: _editCommentController,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
              style: AppTheme.sans(fontSize: 13),
            )
          else
            Text(
              comment.text,
              style: AppTheme.sans(fontSize: 13, color: AppTheme.textPrimary, height: 1.5),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(String reqId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add reviewer note...',
                hintStyle: AppTheme.sans(fontSize: 12, color: AppTheme.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
              ),
              style: AppTheme.sans(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              if (_commentController.text.trim().isEmpty) return;
              final newComment = ReviewComment(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                author: 'Reviewer',
                text: _commentController.text.trim(),
                createdAt: DateTime.now(),
              );
              ref.read(documentProvider.notifier).addComment(reqId, newComment);
              _commentController.clear();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(0, 28),
              side: const BorderSide(color: AppTheme.border),
            ),
            child: Text(
              'Add',
              style: AppTheme.mono(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
