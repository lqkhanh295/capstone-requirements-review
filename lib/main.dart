import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/workspace_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(
    // Adding ProviderScope for riverpod as required in state management (even though Khoa only works on UI, it's good practice)
    const ProviderScope(
      child: CapstoneApp(),
    ),
  );
}

class CapstoneApp extends StatelessWidget {
  const CapstoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capstone Requirements Review',
      theme: AppTheme.lightTheme,
      home: const WorkspaceScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
