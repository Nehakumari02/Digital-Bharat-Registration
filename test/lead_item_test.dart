import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_digital_registration/models/lead_model.dart';
import 'package:the_digital_registration/views/service_forms.dart';

void main() {
  testWidgets('LeadItem renders without crashing', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print(details.exception);
      throw details.exception;
    };
    
    final lead = LeadModel(
      id: 1,
      name: 'Test Farmer',
      loanType: 'Farmer Loan',
      amount: '50000',
      status: 'Pending',
      mobile: '9876543210',
      tableName: 'farmer_loans',
      extraData: {'Land Size': '2 Acres'},
    );
    
    // We have to extract _leadItem or just use AllLeadsScreen with mock?
    // Since _leadItem is private to _AllLeadsScreenState, we can't call it directly.
  });
}
