import 'package:flutter/material.dart';

import '../constants/lead_category.dart';
import '../controllers/lead_controller.dart';
import '../models/lead_model.dart';
import '../views/my_loans_screen.dart';

/// Live loan status pulled from the user's row in `farmer_loans`,
/// `business_loans`, or `student_loans`.
class MyLoanStatusCard extends StatefulWidget {
  const MyLoanStatusCard({
    super.key,
    required this.userId,
    required this.category,
  });

  final int userId;
  final LeadCategory category;

  @override
  State<MyLoanStatusCard> createState() => _MyLoanStatusCardState();
}

class _MyLoanStatusCardState extends State<MyLoanStatusCard> {
  final _controller = LeadController();
  late Future<LeadModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.fetchLatestUserLoan(
      widget.userId,
      category: widget.category,
    );
  }

  void _openDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyLoansScreen(
          userId: widget.userId,
          category: widget.category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LeadModel?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _shell(
            title: widget.category.title,
            status: 'Loading…',
            amount: '',
            onTap: null,
          );
        }

        final loan = snapshot.data;
        if (loan == null) {
          return _shell(
            title: widget.category.title,
            status: 'No application yet',
            amount: 'Tap loan form to apply',
            onTap: null,
          );
        }

        return _shell(
          title: widget.category.title,
          status: loan.status,
          amount: '₹${loan.amount}',
          onTap: _openDetails,
        );
      },
    );
  }

  Widget _shell({
    required String title,
    required String status,
    required String amount,
    required VoidCallback? onTap,
  }) {
    final approved = leadStatusApproved(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: approved
                ? [Colors.green.shade400, Colors.green.shade700]
                : [Colors.orange.shade400, Colors.deepOrange.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (approved ? Colors.green : Colors.orange).withValues(
                alpha: 0.35,
              ),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      approved ? Icons.verified : Icons.pending_actions,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (amount.isNotEmpty)
                          Text(
                            amount,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
