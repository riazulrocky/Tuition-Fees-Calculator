import 'package:flutter_test/flutter_test.dart';
import 'package:tuition_calculator/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our app title is present.
    expect(find.text('Tuition Fees Calculator'), findsOneWidget);

    // Verify that the calculation form is shown.
    expect(find.text('Fee Calculation Form'), findsOneWidget);
  });
}
