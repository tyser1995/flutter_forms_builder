import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_forms_builder/main.dart';

void main() {
  testWidgets('FormBuilderApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FormBuilderApp());
    expect(find.text('Form Builder'), findsOneWidget);
  });
}
