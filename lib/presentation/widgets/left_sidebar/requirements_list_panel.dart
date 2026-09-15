import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_theme.dart';
import 'requirement_card.dart';

class RequirementsListPanel extends StatefulWidget {
  const RequirementsListPanel({super.key});

  @override
  State<RequirementsListPanel> createState() => _RequirementsListPanelState();
}

class _RequirementsListPanelState extends State<RequirementsListPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedTab = 'All';

  // Mock Data for Demo
  final List<Map<String, dynamic>> _mockRequirements = [
    {
      'id': 'REQ-001',
      'title': 'The system shall allow users to upload PDF files.',
      'status': RequirementStatus.passed,
      'issueCount': 0,
    },
    {
      'id': 'REQ-002',
      'title': 'The system must parse document requirements with 99% accuracy.',
      'status': RequirementStatus.needsReview,
      'issueCount': 1,
    },
    {
      'id': 'REQ-003',
      'title': 'Response time for AI review should be under 2 seconds.',
      'status': RequirementStatus.failed,
      'issueCount': 2,
    },
    {
      'id': 'REQ-004',
      'title': 'Users can export reports as CSV.',
      'status': RequirementStatus.notReviewed,
      'issueCount': 0,
    },
  ];

  int _selectedIndex = -1;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearchShortcut() {
    _searchFocusNode.requestFocus();
  }

  void _handleArrowUp() {
    if (_selectedIndex > 0) {
      setState(() => _selectedIndex--);
    }
  }

  void _handleArrowDown() {
    if (_selectedIndex < _mockRequirements.length - 1) {
      setState(() => _selectedIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const ArrowUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const ArrowDownIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SearchIntent: CallbackAction<SearchIntent>(onInvoke: (intent) => _handleSearchShortcut()),
          ArrowUpIntent: CallbackAction<ArrowUpIntent>(onInvoke: (intent) => _handleArrowUp()),
          ArrowDownIntent: CallbackAction<ArrowDownIntent>(onInvoke: (intent) => _handleArrowDown()),
        },
        child: Focus(
          autofocus: true,
          child: Container(
            width: 260, // Slightly wider for better breathing room
            decoration: const BoxDecoration(
              color: AppTheme.background,
              border: Border(
                right: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildTabFilters(),
                const Divider(),
                Expanded(child: _buildList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              '${_mockRequirements.length}',
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

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _mockRequirements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = _mockRequirements[index];
        return RequirementCard(
          id: req['id'],
          title: req['title'],
          status: req['status'],
          issueCount: req['issueCount'],
          isSelected: _selectedIndex == index,
          onTap: () => setState(() => _selectedIndex = index),
        );
      },
    );
  }
}

class SearchIntent extends Intent { const SearchIntent(); }
class ArrowUpIntent extends Intent { const ArrowUpIntent(); }
class ArrowDownIntent extends Intent { const ArrowDownIntent(); }
