import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:capstone_requirements_review/main.dart';
import 'package:capstone_requirements_review/presentation/screens/workspace_screen.dart';

void main() {
  testWidgets('App loads WorkspaceScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: CapstoneApp()));

    // Verify that our WorkspaceScreen is loaded
    expect(find.byType(WorkspaceScreen), findsOneWidget);
  });
}
