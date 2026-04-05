import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_points_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ClothingPointsApp());
    expect(find.byType(ClothingPointsApp), findsOneWidget);
  });
}
