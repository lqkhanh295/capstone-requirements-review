import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_theme.dart';
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
    final query = _searchController.text.toLowerCase();
    return allReqs.where((req) {
      final matchesSearch = req.id.toLowerCase().contains(query) ||
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
                _buildHeader(filteredReqs.length),
                _buildSearchBar(),
                _buildTabFilters(),
                const Divider(),
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'REQUIREMENTS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) => setState(() {}),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search (Ctrl+F)',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppTheme.textSecondary),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildTabFilters() {
    final tabs = ['All', 'Review', 'Failed'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceHover,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius - 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ]
              : [],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Requirement> reqs, Requirement? selectedReq) {
    if (reqs.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy yêu cầu nào.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reqs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = reqs[index];
        final isSelected = selectedReq?.id == req.id;
        
        // Calculate issue count from AI review if available
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
