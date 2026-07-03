import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_digital_registration/constants/lead_category.dart';
import 'package:the_digital_registration/models/lead_model.dart';

void main() {
  testWidgets('AllLeadsScreen narrow width', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print("CAUGHT: ${details.exception}");
      throw details.exception;
    };
    
    // Set a very narrow size!
    tester.view.physicalSize = const Size(120, 1080);
    tester.view.devicePixelRatio = 1.0;
    
    final leads = [
      LeadModel(
        id: 1,
        name: 'Test Farmer',
        loanType: 'Farmer Loan',
        amount: '50000',
        status: 'Pending',
        mobile: '9876543210',
        tableName: 'farmer_loans',
        extraData: {'Land Size': '2 Acres'},
      ),
    ];
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: leads.map((lead) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                            const SizedBox(width: 8),
                            Flexible(child: Text(lead.amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF26522)), textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(lead.loanType, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                                const SizedBox(width: 12),
                                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(lead.mobile, style: TextStyle(color: Colors.grey.shade700)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text("PENDING"),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          child: Text("CLAIM"),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}
