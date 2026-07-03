// lib/models/lead_model.dart

import 'dart:convert';

class LeadModel {
  final int id;
  final String name;
  final String loanType;
  final String amount;
  final String status;
  final String mobile;
  final String tableName;
  final Map<String, dynamic> extraData;
  final int? claimedBy; // ID of the bank that claimed this lead

  LeadModel({
    required this.id,
    required this.name,
    required this.loanType,
    required this.amount,
    required this.status,
    required this.mobile,
    required this.tableName,
    required this.extraData,
    this.claimedBy,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    try {
      Map<String, dynamic> parsedExtra = {};
      if (json['extra_data'] != null) {
        if (json['extra_data'] is String) {
          parsedExtra.addAll(jsonDecode(json['extra_data']));
        } else if (json['extra_data'] is Map) {
          parsedExtra.addAll(Map<String, dynamic>.from(json['extra_data']));
        }
      }
      if (json['details'] != null) {
        if (json['details'] is String) {
          parsedExtra.addAll(jsonDecode(json['details']));
        } else if (json['details'] is Map) {
          parsedExtra.addAll(Map<String, dynamic>.from(json['details']));
        }
      }

      int? claimedBy;
      if (json['claimed_by'] != null) {
        final parsed = int.tryParse(json['claimed_by'].toString());
        // Treat 0 as unclaimed (DB default is 0)
        claimedBy = (parsed != null && parsed > 0) ? parsed : null;
      }

      return LeadModel(
        id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
        name: (json['name'] ?? json['company_name'] ?? 'N/A').toString(),
        loanType: (json['loan_type'] ?? 'Service').toString(),
        amount: (json['amount'] ?? json['price'] ?? '0').toString(),
        status: (json['status'] ?? 'Pending').toString(),
        mobile: (json['mobile'] ?? 'N/A').toString(),
        tableName: (json['table_name'] ?? 'farmer_loans').toString(),
        extraData: parsedExtra,
        claimedBy: claimedBy,
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
        tableName: "error",
        extraData: {},
      );
    }
  }
}