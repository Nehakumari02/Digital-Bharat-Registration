// lib/models/lead_model.dart

class LeadModel {
  final int id;
  final String name;
  final String loanType;
  final String amount;
  final String status;
  final String mobile;

  LeadModel({
    required this.id,
    required this.name,
    required this.loanType,
    required this.amount,
    required this.status,
    required this.mobile,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      loanType: json['loan_type'] ?? 'General',
      amount: "₹${json['amount']}",
      status: json['status'] ?? 'N/A',
      mobile: json['mobile'] ?? 'No Number', // 3. Parse it from JSON
    );
  }
}