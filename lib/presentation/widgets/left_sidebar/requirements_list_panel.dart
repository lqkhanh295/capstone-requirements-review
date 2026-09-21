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
  String _selectedTab = 'All';

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

      switch (_selectedTab) {
        case 'Review':
          return req.status == ReviewStatus.needsReview || 
                 (req.review != null && req.review!.overallScore < 80 && req.review!.overallScore >= 50);
        case 'Failed':
          return req.status == ReviewStatus.failed ||
                 (req.review != null && req.review!.overallScore < 50);
        case 'All':
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
            width: 290,
            decoration: const BoxDecoration(
              color: AppTheme.background,
              border: Border(
                right: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(filteredReqs.length),
                _buildSearchBar(),
                _buildTabFilters(),
                const Divider(height: 1),
                Expanded(child: _buildList(filteredReqs, selectedReq)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'REQUIREMENTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search requirements... (Ctrl+F)',
          hintStyle: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
          prefixIcon: const Icon(LucideIcons.search, size: 15, color: AppTheme.textMuted),
          isDense: true,
          fillColor: AppTheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        ),
      ),
    );
  }

  Widget _buildTabFilters() {
    final tabs = ['All', 'Review', 'Failed'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppTheme.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          children: tabs.map((tab) => Expanded(child: _buildTab(tab))).toList(),
        ),
      ),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton - 2),
          border: isSelected ? Border.all(color: AppTheme.border, width: 0.5) : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Requirement> reqs, Requirement? selectedReq) {
    if (reqs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.searchX, size: 24, color: AppTheme.textMuted),
              SizedBox(height: 8),
              Text(
                'Không tìm thấy yêu cầu nào',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: reqs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
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
