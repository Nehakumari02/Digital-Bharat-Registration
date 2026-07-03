import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_digital_registration/constants/lead_category.dart';
import 'package:the_digital_registration/views/service_forms.dart';

void main() {
  testWidgets('AllLeadsScreen on Desktop', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print(details.exception);
      throw details.exception;
    };
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    
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
