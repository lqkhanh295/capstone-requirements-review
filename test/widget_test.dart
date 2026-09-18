import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:capstone_requirements_review/main.dart';

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
}
