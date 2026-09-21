import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/models.dart';
import '../providers/rubric_provider.dart';

class RubricSelectorDialog extends ConsumerStatefulWidget {
  const RubricSelectorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RubricSelectorDialog(),
    );
  }

  @override
  ConsumerState<RubricSelectorDialog> createState() => _RubricSelectorDialogState();
}

class _RubricSelectorDialogState extends ConsumerState<RubricSelectorDialog> {
  late Rubric _selectedRubric;
  bool _isEditing = false;
  late List<RubricCriterion> _editingCriteria;
  final _rubricNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final current = ref.read(rubricProvider).activeRubric;
    _selectedRubric = current;
    _editingCriteria = List.from(current.criteria);
    _rubricNameController.text = current.name;
  }

  @override
  void dispose() {
    _rubricNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rubricState = ref.watch(rubricProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 780,
        constraints: const BoxConstraints(maxHeight: 680),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header
            _buildHeader(context),

            const Divider(height: 1, color: AppTheme.border),

            // Content Area (Preset List on Left, Details & Weights on Right)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left: Preset Rubrics List
                  Container(
                    width: 260,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: AppTheme.border)),
                      color: AppTheme.surfaceSubtle,
                    ),
                    child: _buildRubricList(rubricState),
                  ),

                  // Right: Detail & Criteria breakdown
                  Expanded(
                    child: _buildRubricDetailView(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppTheme.border),

            // Bottom Actions
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Icon(LucideIcons.scale, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RUBRIC CHẤM ĐIỂM SRS THEO CHUẨN',
                style: AppTheme.mono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tùy chỉnh tiêu chí, trọng số và prompt AI theo chuẩn đồ án trường hoặc doanh nghiệp',
                style: AppTheme.sans(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(LucideIcons.x, size: 18, color: AppTheme.textMuted),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildRubricList(RubricState rubricState) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            'BỘ RUBRICS CÓ SẴN',
            style: AppTheme.mono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        for (final r in rubricState.allRubrics) ...[
          _buildRubricItemCard(r),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildRubricItemCard(Rubric r) {
    final isSelected = _selectedRubric.id == r.id;
    final isActive = ref.read(rubricProvider).activeRubric.id == r.id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRubric = r;
          _isEditing = false;
          _editingCriteria = List.from(r.criteria);
          _rubricNameController.text = r.name;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.statusPassed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: AppTheme.mono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.statusPassed,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              r.organization,
              style: AppTheme.mono(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${r.criteria.length} tiêu chí đánh giá',
              style: AppTheme.mono(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRubricDetailView() {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedRubric.name,
                      style: AppTheme.sans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedRubric.organization} • ${_selectedRubric.criteria.length} tiêu chí',
                      style: AppTheme.mono(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                    if (_isEditing) {
                      _editingCriteria = _selectedRubric.criteria
                          .map((c) => c.copyWith())
                          .toList();
                    }
                  });
                },
                icon: Icon(_isEditing ? LucideIcons.eye : LucideIcons.pencil, size: 13),
                label: Text(
                  _isEditing ? 'Xem mô tả' : 'Chỉnh trọng số (%)',
                  style: AppTheme.mono(fontSize: 11),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.border),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              _selectedRubric.description,
              style: AppTheme.sans(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'DANH SÁCH TIÊU CHÍ & TRỌNG SỐ',
            style: AppTheme.mono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _editingCriteria.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final criterion = _editingCriteria[index];
                return _buildCriterionRow(criterion, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionRow(RubricCriterion criterion, int index) {
    final weightPercent = (criterion.weight * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      criterion.name,
                      style: AppTheme.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '[${criterion.id}]',
                      style: AppTheme.mono(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  criterion.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sans(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (_isEditing) ...[
            SizedBox(
              width: 140,
              child: Slider(
                value: criterion.weight,
                min: 0.05,
                max: 0.60,
                divisions: 11,
                activeColor: AppTheme.primary,
                onChanged: (val) {
                  setState(() {
                    _editingCriteria[index] = criterion.copyWith(weight: val);
                  });
                },
              ),
            ),
          ],
          Container(
            width: 46,
            alignment: Alignment.centerRight,
            child: Text(
              '$weightPercent%',
              style: AppTheme.mono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isActive = ref.watch(rubricProvider).activeRubric.id == _selectedRubric.id;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Text(
            'Hệ số tổng: ${(_editingCriteria.fold<double>(0, (sum, c) => sum + c.weight) * 100).round()}%',
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.border),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Đóng',
              style: AppTheme.sans(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              final updatedRubric = _selectedRubric.copyWith(
                criteria: _editingCriteria,
              );
              ref.read(rubricProvider.notifier).updateRubric(updatedRubric);
              ref.read(rubricProvider.notifier).selectRubric(updatedRubric);

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã kích hoạt rubric: ${updatedRubric.name}'),
                  backgroundColor: AppTheme.statusPassed,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(LucideIcons.check, size: 14),
            label: Text(
              isActive && !_isEditing ? 'Đang kích hoạt' : 'Áp dụng Rubric này',
              style: AppTheme.sans(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textPrimary,
              foregroundColor: AppTheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
