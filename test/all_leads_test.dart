import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_digital_registration/constants/lead_category.dart';
import 'package:the_digital_registration/views/service_forms.dart';

void main() {
  testWidgets('AllLeadsScreen renders without crashing', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      throw Exception(details.exception);
    };
    
    await tester.pumpWidget(
      const MaterialApp(
        home: AllLeadsScreen(
          currentBankUserId: 1,
          category: LeadCategory.business,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AllLeadsScreen), findsOneWidget);
  });
}
