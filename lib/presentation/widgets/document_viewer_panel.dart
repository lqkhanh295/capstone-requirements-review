import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/models.dart';
import '../providers/document_provider.dart';

class DocumentViewerPanel extends ConsumerStatefulWidget {
  final VoidCallback? onSwitchToDetail;

  const DocumentViewerPanel({
    super.key,
    this.onSwitchToDetail,
  });

  @override
  ConsumerState<DocumentViewerPanel> createState() => _DocumentViewerPanelState();
}

class _DocumentViewerPanelState extends ConsumerState<DocumentViewerPanel> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  static const double _lineHeight = 24.0;
  String? _lastScrolledReqId;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToRequirement(Requirement req, {bool animate = true}) {
    if (req.startLine == null) return;

    final targetLine = max(1, req.startLine!);
    // Center the target line approximately in the viewport
    final targetOffset = max(0.0, ((targetLine - 1) * _lineHeight) - 150.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animate) {
        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _scrollController.jumpTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentProvider);
    final doc = docState.document;

    if (doc == null) {
      return const Center(
        child: Text('Chưa có tài liệu nào được mở.'),
      );
    }

    final selectedReq = docState.selectedRequirement;
    final lines = doc.lines;

    // Auto-scroll when selected requirement changes
    if (selectedReq != null && selectedReq.id != _lastScrolledReqId && selectedReq.startLine != null) {
      _lastScrolledReqId = selectedReq.id;
      _scrollToRequirement(selectedReq);
    }

    return Container(
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          _buildToolbar(doc, selectedReq, lines.length),

          const Divider(height: 1, color: AppTheme.border),

          // Document Text Viewer with Line Numbers
          Expanded(
            child: lines.isEmpty
                ? Center(
                    child: Text(
                      'Tài liệu không có nội dung văn bản để hiển thị.',
                      style: AppTheme.mono(color: AppTheme.textMuted),
                    ),
                  )
                : _buildLinesList(doc, selectedReq, lines),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(Document doc, Requirement? selectedReq, int totalLines) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.surfaceSubtle,
      child: Row(
        children: [
          const Icon(LucideIcons.fileText, size: 14, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(
            'SOURCE VIEW',
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              '$totalLines LINES',
              style: AppTheme.mono(
                fontSize: 10,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          // Search in document
          Container(
            width: 180,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              border: Border.all(color: AppTheme.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(LucideIcons.search, size: 12, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    style: AppTheme.mono(fontSize: 11),
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm dòng...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(LucideIcons.x, size: 12, color: AppTheme.textMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (selectedReq != null && selectedReq.startLine != null) ...[
            ElevatedButton.icon(
              onPressed: () => _scrollToRequirement(selectedReq),
              icon: const Icon(LucideIcons.locateFixed, size: 12),
              label: Text(
                'Jump to ${selectedReq.id}',
                style: AppTheme.mono(fontSize: 10, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (widget.onSwitchToDetail != null)
            OutlinedButton.icon(
              onPressed: widget.onSwitchToDetail,
              icon: const Icon(LucideIcons.clipboardCheck, size: 12),
              label: Text(
                'Chi tiết đánh giá',
                style: AppTheme.sans(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.border),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLinesList(Document doc, Requirement? selectedReq, List<String> lines) {
    final lineNumberWidth = (lines.length.toString().length * 9.0 + 24.0).clamp(48.0, 72.0);

    return ListView.builder(
      controller: _scrollController,
      itemCount: lines.length,
      itemExtent: _lineHeight,
      itemBuilder: (context, index) {
        final lineNum = index + 1;
        final rawLine = lines[index];
        final isMatchSearch = _searchQuery.isNotEmpty && rawLine.toLowerCase().contains(_searchQuery);

        // Check if this line belongs to the selected requirement
        final bool isHighlighted;
        final bool isFirstHighlightedLine;
        final bool isLastHighlightedLine;

        if (selectedReq != null && selectedReq.startLine != null) {
          final s = selectedReq.startLine!;
          final e = selectedReq.endLine ?? s;
          isHighlighted = lineNum >= s && lineNum <= e;
          isFirstHighlightedLine = lineNum == s;
          isLastHighlightedLine = lineNum == e;
        } else {
          isHighlighted = false;
          isFirstHighlightedLine = false;
          isLastHighlightedLine = false;
        }

        // Find which requirement (if any) owns this line
        final ownerReq = doc.requirements.firstWhere(
          (r) => (r.startLine != null && lineNum >= r.startLine! && lineNum <= (r.endLine ?? r.startLine!)),
          orElse: () => const Requirement(id: '', title: '', description: ''),
        );
        final hasOwner = ownerReq.id.isNotEmpty;

        return InkWell(
          onTap: () {
            if (hasOwner) {
              ref.read(documentProvider.notifier).selectRequirement(ownerReq);
            }
          },
          child: Container(
            height: _lineHeight,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppTheme.primary.withValues(alpha: 0.10)
                  : (isMatchSearch
                      ? Colors.amber.withValues(alpha: 0.2)
                      : (index % 2 == 1 ? AppTheme.surfaceSubtle.withValues(alpha: 0.4) : AppTheme.surface)),
              border: Border(
                left: BorderSide(
                  color: isHighlighted
                      ? AppTheme.primary
                      : (hasOwner ? AppTheme.border : Colors.transparent),
                  width: isHighlighted ? 3.5 : 1,
                ),
                top: isFirstHighlightedLine
                    ? const BorderSide(color: AppTheme.primary, width: 1)
                    : BorderSide.none,
                bottom: isLastHighlightedLine
                    ? const BorderSide(color: AppTheme.primary, width: 1)
                    : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                // Line number column
                Container(
                  width: lineNumberWidth,
                  padding: const EdgeInsets.only(right: 12),
                  alignment: Alignment.centerRight,
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: AppTheme.border)),
                  ),
                  child: Text(
                    '$lineNum',
                    style: AppTheme.mono(
                      fontSize: 11,
                      color: isHighlighted ? AppTheme.primary : AppTheme.textMuted,
                      fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Optional Badge for Requirement ID on the first line of the requirement
                if (isFirstHighlightedLine && selectedReq != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      selectedReq.id,
                      style: AppTheme.mono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ] else if (hasOwner && !isHighlighted && ownerReq.startLine == lineNum) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      ownerReq.id,
                      style: AppTheme.mono(
                        fontSize: 9,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],

                // Line content text
                Expanded(
                  child: Text(
                    rawLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.mono(
                      fontSize: 12,
                      color: isHighlighted ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
