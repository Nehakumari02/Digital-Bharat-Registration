import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_digital_registration/constants/lead_category.dart';
import 'package:the_digital_registration/models/lead_model.dart';
import 'package:the_digital_registration/views/service_forms.dart';

void main() {
  testWidgets('AllLeadsScreen renders with data without crashing', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print(details.exception);
      throw details.exception;
    };
    await tester.pumpWidget(
      const MaterialApp(
        home: AllLeadsScreen(
          currentBankUserId: 1,
          category: LeadCategory.farmer,
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}
