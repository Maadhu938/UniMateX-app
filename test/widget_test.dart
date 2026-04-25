import 'package:flutter_test/flutter_test.dart';
import 'package:unimatex/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UniMateXApp());
    await tester.pumpAndSettle();
    expect(find.byType(UniMateXApp), findsOneWidget);
  });
}
