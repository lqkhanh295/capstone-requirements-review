import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/models.dart';
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
      const SnackBar(
        content: Text('Đã lưu trạng thái phiên review hiện tại.'),
        duration: Duration(seconds: 2),
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
                  padding: const EdgeInsets.all(AppTheme.space24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDescription(selectedReq),
                      const SizedBox(height: AppTheme.space32),
                      _buildManualReviewSection(selectedReq),
                      const SizedBox(height: AppTheme.space32),
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
            Icon(
              LucideIcons.mousePointerClick,
              size: 48,
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.space16),
            const Text(
              'Chưa chọn Requirement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.space8),
            const Text(
              'Chọn một yêu cầu từ danh sách bên trái để xem chi tiết',
              style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Requirement req) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space16,
      ),
      color: AppTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  req.id,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              _buildTypeBadge(req.type),
              const Spacer(),
              if (req.sourceLocation.isNotEmpty) ...[
                const Icon(
                  LucideIcons.fileText,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Trang ${req.sourceLocation}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          Text(
            req.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(RequirementType type) {
    Color bg;
    Color fg;
    switch (type) {
      case RequirementType.functional:
        bg = AppTheme.primary.withOpacity(0.1);
        fg = AppTheme.primary;
        break;
      case RequirementType.nonFunctional:
        bg = AppTheme.statusNeedsReview.withOpacity(0.1);
        fg = AppTheme.statusNeedsReview;
        break;
      case RequirementType.security:
        bg = AppTheme.statusFailed.withOpacity(0.1);
        fg = AppTheme.statusFailed;
        break;
      case RequirementType.performance:
        bg = Colors.purple.withOpacity(0.1);
        fg = Colors.purple;
        break;
      default:
        bg = AppTheme.border;
        fg = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Text(
        type.label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildDescription(Requirement req) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MÔ TẢ YÊU CẦU',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppTheme.space12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.space16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Text(
            req.description.isNotEmpty
                ? req.description
                : 'Không có mô tả chi tiết.',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualReviewSection(Requirement req) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRẠNG THÁI ĐÁNH GIÁ THỦ CÔNG',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppTheme.space12),
        Wrap(
          spacing: AppTheme.space8,
          runSpacing: AppTheme.space8,
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
    IconData icon;

    switch (status) {
      case ReviewStatus.passed:
        activeColor = AppTheme.statusPassed;
        icon = LucideIcons.checkCircle2;
        break;
      case ReviewStatus.needsReview:
        activeColor = AppTheme.statusNeedsReview;
        icon = LucideIcons.alertCircle;
        break;
      case ReviewStatus.failed:
        activeColor = AppTheme.statusFailed;
        icon = LucideIcons.xCircle;
        break;
      case ReviewStatus.notReviewed:
        activeColor = AppTheme.statusNotReviewed;
        icon = LucideIcons.helpCircle;
        break;
    }

    return InkWell(
      onTap: () {
        ref
            .read(documentProvider.notifier)
            .updateRequirementStatus(reqId, status);
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space16,
          vertical: AppTheme.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.1)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.space8),
            Text(
              status.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : AppTheme.textPrimary,
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
        const Text(
          'GHI CHÚ REVIEWER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppTheme.space12),
        if (req.comments.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: req.comments.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppTheme.space12),
            itemBuilder: (context, index) {
              final comment = req.comments[index];
              return _buildCommentItem(req.id, comment);
            },
          ),
          const SizedBox(height: AppTheme.space16),
        ],
        _buildCommentInput(req.id),
      ],
    );
  }

  Widget _buildCommentItem(String reqId, ReviewComment comment) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: const Icon(
                  LucideIcons.user,
                  size: 14,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: AppTheme.space8),
              Text(
                comment.author,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: AppTheme.space8),
              Text(
                dateFormat.format(comment.createdAt),
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
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
                const SizedBox(width: AppTheme.space12),
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
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                InkWell(
                  onTap: () {
                    ref
                        .read(documentProvider.notifier)
                        .deleteComment(reqId, comment.id);
                  },
                  child: const Icon(
                    LucideIcons.trash2,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.space8),
          if (_editingCommentId == comment.id)
            TextField(
              controller: _editCommentController,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(AppTheme.space8),
              ),
              style: const TextStyle(fontSize: 14),
            )
          else
            Text(
              comment.text,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(String reqId) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Thêm ghi chú review mới...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          IconButton(
            onPressed: () {
              if (_commentController.text.trim().isEmpty) return;
              final newComment = ReviewComment(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                author: 'Me',
                text: _commentController.text.trim(),
                createdAt: DateTime.now(),
              );
              ref.read(documentProvider.notifier).addComment(reqId, newComment);
              _commentController.clear();
            },
            icon: const Icon(
              LucideIcons.sendHorizonal,
              color: AppTheme.primary,
            ),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
