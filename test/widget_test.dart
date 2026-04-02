import 'package:flutter_test/flutter_test.dart';
import 'package:road_survey/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const RoadSurveyApp());
    expect(find.text('ROAD SURVEY'), findsOneWidget);
  });
}