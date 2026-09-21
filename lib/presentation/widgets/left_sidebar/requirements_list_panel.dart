import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../providers/document_provider.dart';
import 'requirement_card.dart';

class RequirementsListPanel extends ConsumerStatefulWidget {
  const RequirementsListPanel({super.key});

  @override
  ConsumerState<RequirementsListPanel> createState() => _RequirementsListPanelState();
}

class _RequirementsListPanelState extends ConsumerState<RequirementsListPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedFilter = 'ALL'; // ALL, OPEN, ISSUES, RESOLVED

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearchShortcut() {
    _searchFocusNode.requestFocus();
  }

  void _handleArrowUp(List<Requirement> reqs, Requirement? selectedReq) {
    if (reqs.isEmpty) return;
    if (selectedReq == null) {
      ref.read(documentProvider.notifier).selectRequirement(reqs.last);
      return;
    }
    final index = reqs.indexWhere((r) => r.id == selectedReq.id);
    if (index > 0) {
      ref.read(documentProvider.notifier).selectRequirement(reqs[index - 1]);
    }
  }

  void _handleArrowDown(List<Requirement> reqs, Requirement? selectedReq) {
    if (reqs.isEmpty) return;
    if (selectedReq == null) {
      ref.read(documentProvider.notifier).selectRequirement(reqs.first);
      return;
    }
    final index = reqs.indexWhere((r) => r.id == selectedReq.id);
    if (index < reqs.length - 1) {
      ref.read(documentProvider.notifier).selectRequirement(reqs[index + 1]);
    }
  }

  List<Requirement> _getFilteredRequirements(List<Requirement> allReqs) {
    final query = _searchController.text.toLowerCase().trim();
    return allReqs.where((req) {
      final matchesSearch = query.isEmpty ||
          req.id.toLowerCase().contains(query) ||
          req.title.toLowerCase().contains(query);
      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case 'OPEN':
          return req.status == ReviewStatus.notReviewed;
        case 'ISSUES':
          return req.status == ReviewStatus.failed ||
              req.status == ReviewStatus.needsReview ||
              (req.review != null && req.review!.issues.isNotEmpty);
        case 'RESOLVED':
          return req.status == ReviewStatus.passed;
        case 'ALL':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentProvider);
    final allReqs = docState.document?.requirements ?? [];
    final filteredReqs = _getFilteredRequirements(allReqs);
    final selectedReq = docState.selectedRequirement;

    final allCount = allReqs.length;
    final openCount = allReqs.where((r) => r.status == ReviewStatus.notReviewed).length;
    final issuesCount = allReqs.where((r) =>
        r.status == ReviewStatus.failed ||
        r.status == ReviewStatus.needsReview ||
        (r.review != null && r.review!.issues.isNotEmpty)).length;
    final resolvedCount = allReqs.where((r) => r.status == ReviewStatus.passed).length;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const ArrowUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const ArrowDownIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SearchIntent: CallbackAction<SearchIntent>(onInvoke: (intent) => _handleSearchShortcut()),
          ArrowUpIntent: CallbackAction<ArrowUpIntent>(onInvoke: (intent) => _handleArrowUp(filteredReqs, selectedReq)),
          ArrowDownIntent: CallbackAction<ArrowDownIntent>(onInvoke: (intent) => _handleArrowDown(filteredReqs, selectedReq)),
        },
        child: Focus(
          autofocus: true,
          child: Container(
            width: 300,
            decoration: const BoxDecoration(
              color: AppTheme.background,
              border: Border(
                right: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Editorial Section: DOCUMENTS
                _buildDocumentsSection(docState.document),
                const Divider(height: 1),

                // Review Status Filters
                _buildReviewFilterSection(
                  allCount: allCount,
                  openCount: openCount,
                  issuesCount: issuesCount,
                  resolvedCount: resolvedCount,
                ),
                const Divider(height: 1),

                // Search Bar
                _buildSearchBar(),
                const Divider(height: 1),

                // Requirements Section Title
                _buildSectionHeader('REQUIREMENTS', filteredReqs.length),

                // Requirements List
                Expanded(child: _buildList(filteredReqs, selectedReq)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(Document? doc) {
    final docName = doc?.name ?? 'No document loaded';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DOCUMENTS',
            style: AppTheme.mono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '01',
                style: AppTheme.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  docName,
                  style: AppTheme.sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewFilterSection({
    required int allCount,
    required int openCount,
    required int issuesCount,
    required int resolvedCount,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REVIEW',
            style: AppTheme.mono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          _buildFilterRow('ALL', allCount),
          _buildFilterRow('OPEN', openCount),
          _buildFilterRow('ISSUES', issuesCount),
          _buildFilterRow('RESOLVED', resolvedCount),
        ],
      ),
    );
  }

  Widget _buildFilterRow(String label, int count) {
    final isSelected = _selectedFilter == label;

    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      hoverColor: AppTheme.surfaceHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 10),
            Text(
              label,
              style: AppTheme.sans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$count',
              style: AppTheme.mono(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.surfaceSubtle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.mono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            '$count',
            style: AppTheme.mono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) => setState(() {}),
        style: AppTheme.sans(
          fontSize: 12,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Filter requirements... (Ctrl+F)',
          hintStyle: AppTheme.sans(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
          prefixIcon: const Icon(LucideIcons.search, size: 14, color: AppTheme.textSecondary),
          isDense: true,
          fillColor: AppTheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        ),
      ),
    );
  }

  Widget _buildList(List<Requirement> reqs, Requirement? selectedReq) {
    if (reqs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No matching requirements',
            style: AppTheme.mono(fontSize: 11, color: AppTheme.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: reqs.length,
      itemBuilder: (context, index) {
        final req = reqs[index];
        final isSelected = selectedReq?.id == req.id;

        int issueCount = 0;
        if (req.review != null && req.review!.issues.isNotEmpty) {
          issueCount = req.review!.issues.length;
        }

        return RequirementCard(
          id: req.id,
          title: req.title,
          status: req.status,
          issueCount: issueCount,
          isSelected: isSelected,
          onTap: () {
            ref.read(documentProvider.notifier).selectRequirement(req);
          },
        );
      },
    );
  }
}

class SearchIntent extends Intent { const SearchIntent(); }
class ArrowUpIntent extends Intent { const ArrowUpIntent(); }
class ArrowDownIntent extends Intent { const ArrowDownIntent(); }
