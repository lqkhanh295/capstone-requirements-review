import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:capstone_requirements_review/main.dart';
import 'package:capstone_requirements_review/domain/models/models.dart';
import 'package:capstone_requirements_review/domain/services/ai_service.dart';
import 'package:capstone_requirements_review/presentation/providers/ai_providers.dart';
import 'package:capstone_requirements_review/presentation/providers/document_provider.dart';
import 'package:capstone_requirements_review/presentation/providers/document_state.dart';
import 'package:capstone_requirements_review/presentation/widgets/ai_review_panel.dart';

void main() {
  testWidgets('App smoke test - renders file drop zone and upload options', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CapstoneRequirementsApp(),
      ),
    );

    expect(find.text('Capstone Requirements Review'), findsWidgets);
    expect(find.text('Nhập tài liệu yêu cầu (SRS)'), findsOneWidget);
    expect(find.text('Chọn tệp từ máy tính'), findsOneWidget);
  });

  testWidgets('AIReviewPanel renders correctly with AIProviderType without NoSuchMethodError', (WidgetTester tester) async {
    const requirement = Requirement(
      id: 'FR-001',
      title: 'Open Document',
      description: 'The system shall allow users to open SRS documents.',
      type: RequirementType.functional,
    );

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    for (final provider in AIProviderType.values) {
      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey(provider),
          overrides: [
            aiConfigProvider.overrideWith(() => _TestAIConfigNotifier(provider)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AIReviewPanel(requirement: requirement),
            ),
          ),
        ),
      );

      // Verify header and provider tag render properly
      expect(find.text('AI Review & Analysis'), findsOneWidget);
      expect(find.text(provider.name.toUpperCase()), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Full workspace layout renders 3 columns when document is loaded', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final doc = Document(
      id: 'doc-1',
      name: 'Test_SRS.pdf',
      filePath: '/path/to/Test_SRS.pdf',
      fileSize: 10240,
      fileType: 'pdf',
      importedAt: DateTime.now(),
      requirements: const [
        Requirement(
          id: 'FR-001',
          title: 'Open Document',
          description: 'The system shall allow users to open SRS documents.',
          type: RequirementType.functional,
        ),
      ],
    );

    final container = ProviderContainer();
    container.read(documentProvider.notifier).state = container.read(documentProvider.notifier).state.copyWith(
      status: DocumentStatus.loaded,
      document: doc,
      selectedRequirement: doc.requirements.first,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CapstoneRequirementsApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify 3 columns render cleanly
    expect(find.text('Open Document'), findsWidgets);
    expect(find.text('AI Review & Analysis'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestAIConfigNotifier extends AIConfigNotifier {
  final AIProviderType _initialProvider;
  _TestAIConfigNotifier(this._initialProvider);

  @override
  AIServiceConfig build() {
    return AIServiceConfig(
      provider: _initialProvider,
      model: _initialProvider.defaultModel,
    );
  }
}
