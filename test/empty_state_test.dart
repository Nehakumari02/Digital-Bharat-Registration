import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Empty state renders without crashing', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print(details.exception);
      throw details.exception;
    };
    
    final debugInfo = "User ID: 23\nCategory: Farmer Loans\nTable: farmer_loans\nURL: http://127.0.0.1:8000/api/leads?bank_user_id=23&type=Farmer%20Loan&table=farmer_loans";
    final effectiveId = 23;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text("Test")),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Text(debugInfo, style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontFamily: 'Courier')),
                  ),
                  const SizedBox(height: 20),
                  Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "No leads available",
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Check back later for new requests.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (effectiveId != 1)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF26522)),
                      child: const Text("Switch to Test ID (1)", style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}
