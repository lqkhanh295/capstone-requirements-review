import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/left_sidebar/requirements_list_panel.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // Left Sidebar (Khoa's Module)
          const RequirementsListPanel(),
          
          // Main Content (Dat's Module - Placeholder)
          Expanded(
            child: Container(
              color: AppTheme.surface,
              child: Center(
                child: Text(
                  'Main Content (Dat)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          
          // AI Review Panel (Thinh's Module - Placeholder)
          Container(
            width: 350,
            decoration: const BoxDecoration(
              color: AppTheme.background,
              border: Border(
                left: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Center(
              child: Text(
                'AI Review Panel (Thinh)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
