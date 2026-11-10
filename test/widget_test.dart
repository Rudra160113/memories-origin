import 'package:flutter_test/flutter_test.dart';
import 'package:memories/main.dart';

void main() {
  testWidgets('Memories app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoriesApp());
    expect(find.text('Memories'), findsWidgets);
  });
}
