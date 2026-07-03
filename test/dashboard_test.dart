import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_digital_registration/views/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen renders without crashing', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print(details.exception);
      throw details.exception;
    };
    
    // Set a desktop size to trigger the desktop layout!
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          userData: {
            'id': 1,
            'name': 'Test User',
            'mobile': '1234567890',
            'category': 'Bank',
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}
