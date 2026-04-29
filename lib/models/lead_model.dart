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
    try {
      return LeadModel(
        id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
        name: (json['name'] ?? json['company_name'] ?? 'N/A').toString(),
        loanType: (json['loan_type'] ?? 'Service').toString(),
        amount: (json['amount'] ?? json['price'] ?? '0').toString(),
        status: (json['status'] ?? 'Pending').toString(),
        mobile: (json['mobile'] ?? 'N/A').toString(),
      );
    } catch (e) {
      print("LeadModel Parsing Error: $e for JSON: $json");
      return LeadModel(
        id: 0,
        name: "Parsing Error",
        loanType: "Error",
        amount: "0",
        status: "Error",
        mobile: "N/A",
      );
    }
  }
}