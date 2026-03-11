import 'package:flutter/material.dart';
import '../models/lead_model.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;

  const LeadCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          lead.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(lead.loanType),
        trailing: Text(
          lead.amount,
          style: const TextStyle(
            color: Color(0xFFF26522),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}