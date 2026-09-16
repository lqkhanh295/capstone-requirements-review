import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'core/theme/app_theme.dart';
import 'core/window/window_config.dart';
import 'domain/models/models.dart';
import 'presentation/common/keyboard_shortcuts.dart';
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/export/export_report_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowConfig.initializeWindow();

  runApp(
    const ProviderScope(
      child: CapstoneReviewApp(),
    ),
  );
}

class CapstoneReviewApp extends StatelessWidget {
  const CapstoneReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: WindowConfig.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedTabIndex = 0; // 0 = Workspace, 1 = Dashboard

  // Sample Mock Document according to SRS specs for testing & demonstration
  final Document _mockDocument = Document(
    id: 'DOC-2026-001',
    name: 'Capstone_Requirements_Review_SRS_v1.0.pdf',
    filePath: 'C:/Docs/Capstone_Requirements_Review_SRS_v1.0.pdf',
    fileType: 'pdf',
    fileSize: 61910,
    importedAt: DateTime.now().subtract(const Duration(hours: 2)),
    requirements: [
      Requirement(
        id: 'REQ-001',
        title: 'Document Upload & Parsing Engine',
        description:
            'System shall allow user to upload PDF, DOCX, TXT, MD files and parse structured requirements.',
        type: RequirementType.functional,
        status: ReviewStatus.passed,
        sourceLocation: 'Section 4.1, Page 5',
        review: const RequirementReview(
          overallScore: 92,
          scores: QualityScores(
            clarity: 95,
            completeness: 90,
            testability: 90,
            consistency: 95,
            feasibility: 90,
          ),
          issues: [],
          suggestedRevision: null,
        ),
        comments: [
          ReviewComment(
            id: 'C-01',
            author: 'Reviewer Khanh',
            text: 'Parsing engine handles all specified file types smoothly.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
          ),
        ],
      ),
      Requirement(
        id: 'REQ-002',
        title: '3-Column Desktop IDE Interface Layout',
        description:
            'Application interface shall follow a 3-column desktop layout with left sidebar, main workspace, and right AI review panel.',
        type: RequirementType.usability,
        status: ReviewStatus.passed,
        sourceLocation: 'Section 5.2, Page 8',
        review: const RequirementReview(
          overallScore: 88,
          scores: QualityScores(
            clarity: 90,
            completeness: 85,
            testability: 90,
            consistency: 90,
            feasibility: 85,
          ),
          issues: [],
        ),
      ),
      Requirement(
        id: 'REQ-003',
        title: 'AI Quality Criteria Multi-dimensional Evaluation',
        description:
            'AI engine shall evaluate requirements across 7 quality dimensions including clarity, completeness, and testability.',
        type: RequirementType.functional,
        status: ReviewStatus.needsReview,
        sourceLocation: 'Section 4.2, Page 6',
        review: const RequirementReview(
          overallScore: 74,
          scores: QualityScores(
            clarity: 70,
            completeness: 75,
            testability: 65,
            consistency: 80,
            feasibility: 80,
          ),
          issues: [
            ReviewIssue(
              type: 'Ambiguity',
              severity: IssueSeverity.medium,
              description:
                  'Definition of 7 quality criteria needs explicit mathematical threshold weighting.',
            ),
          ],
          suggestedRevision:
              'AI engine shall evaluate requirements across clarity, completeness, testability, consistency, and feasibility using 0-100 weighted scoring.',
        ),
      ),
      Requirement(
        id: 'REQ-004',
        title: 'PDF & CSV Summary Report Export',
        description:
            'System shall support exporting review results to print-ready PDF and Excel CSV table formats via Ctrl+E shortcut.',
        type: RequirementType.functional,
        status: ReviewStatus.passed,
        sourceLocation: 'Section 6.2, Page 12',
        review: const RequirementReview(
          overallScore: 96,
          scores: QualityScores(
            clarity: 98,
            completeness: 95,
            testability: 95,
            consistency: 96,
            feasibility: 96,
          ),
          issues: [],
        ),
      ),
      Requirement(
        id: 'REQ-005',
        title: 'Isolate Background Async Task Execution',
        description:
            'Heavy processing tasks such as parsing and report generation must execute on background isolates without blocking UI rendering thread.',
        type: RequirementType.performance,
        status: ReviewStatus.failed,
        sourceLocation: 'Section 9.1, Page 15',
        review: const RequirementReview(
          overallScore: 55,
          scores: QualityScores(
            clarity: 50,
            completeness: 60,
            testability: 50,
            consistency: 60,
            feasibility: 55,
          ),
          issues: [
            ReviewIssue(
              type: 'Completeness',
              severity: IssueSeverity.high,
              description:
                  'Missing max memory consumption bound and isolate error handling timeout criteria.',
            ),
          ],
          suggestedRevision:
              'Heavy parsing and PDF rendering tasks shall run asynchronously via Dart isolates with a 30-second execution timeout.',
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return GlobalKeyboardShortcuts(
      currentDocument: _mockDocument,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                bottom: BorderSide(color: AppTheme.border),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                child: Row(
                  children: [
                    // Brand / Logo
                    const Row(
                      children: [
                        Icon(LucideIcons.fileSearch,
                            color: AppTheme.primary, size: 22),
                        SizedBox(width: AppTheme.space8),
                        Text(
                          'Capstone Review IDE',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppTheme.space32),

                    // Navigation Tabs
                    Row(
                      children: [
                        _buildNavTab(
                          index: 0,
                          icon: LucideIcons.layoutGrid,
                          label: 'Requirements Workspace',
                        ),
                        const SizedBox(width: AppTheme.space8),
                        _buildNavTab(
                          index: 1,
                          icon: LucideIcons.barChart3,
                          label: 'Review Dashboard',
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Shortcut badge hint
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space8,
                        vertical: AppTheme.space4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.keyboard,
                              size: 14, color: AppTheme.textMuted),
                          SizedBox(width: 4),
                          Text(
                            'Export: Ctrl + E',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),

                    // Quick Export Button
                    ElevatedButton.icon(
                      onPressed: () =>
                          ExportReportDialog.show(context, _mockDocument),
                      icon: const Icon(LucideIcons.download, size: 16),
                      label: const Text('Export Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.space16,
                          vertical: AppTheme.space12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: _selectedTabIndex,
          children: [
            // Tab 0: Workspace view placeholder / overview
            _buildWorkspacePlaceholder(),

            // Tab 1: Review Dashboard Screen
            DashboardScreen(
              document: _mockDocument,
              onNavigateToRequirement: (reqId) {
                setState(() {
                  _selectedTabIndex = 0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigated to requirement $reqId'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTabIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space12,
          vertical: AppTheme.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspacePlaceholder() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(AppTheme.space32),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.layoutGrid,
                size: 48, color: AppTheme.primary),
            const SizedBox(height: AppTheme.space16),
            const Text(
              'Requirements Review Workspace',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              'Active Document: ${_mockDocument.name}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedTabIndex = 1),
                  icon: const Icon(LucideIcons.barChart3, size: 18),
                  label: const Text('View Review Dashboard'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space20,
                      vertical: AppTheme.space16,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.space16),
                ElevatedButton.icon(
                  onPressed: () =>
                      ExportReportDialog.show(context, _mockDocument),
                  icon: const Icon(LucideIcons.download, size: 18),
                  label: const Text('Export Report (Ctrl+E)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space20,
                      vertical: AppTheme.space16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
