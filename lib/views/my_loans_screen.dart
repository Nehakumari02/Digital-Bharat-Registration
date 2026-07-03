import 'package:flutter/material.dart';

import '../constants/lead_category.dart';
import '../controllers/lead_controller.dart';
import '../models/lead_model.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import 'service_forms.dart';

/// Shows the logged-in user's own loan applications from the matching DB table
/// (`farmer_loans`, `business_loans`, or `student_loans`).
class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({
    super.key,
    required this.userId,
    required this.category,
  });

  final int userId;
  final LeadCategory category;

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  final _controller = LeadController();
  late Future<List<LeadModel>> _future;
  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<LeadModel>> _load() {
    return _controller.fetchUserLoans(widget.userId, category: widget.category);
  }

  void _refresh() {
    setState(() {
      _refreshKey = UniqueKey();
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My ${widget.category.title}'),
        elevation: 1,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<LeadModel>>(
        key: _refreshKey,
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final loans = snapshot.data ?? [];
          if (loans.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No ${widget.category.title.toLowerCase()} yet',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submit a loan form to track status here.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ResponsiveListView(
            maxWidth: 720,
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              final approved = leadStatusApproved(loan.status);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    '₹${loan.amount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Status: ${loan.status}'),
                      if (loan.extraData.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        ...loan.extraData.entries.take(3).map(
                              (e) => Text('${e.key}: ${e.value}'),
                            ),
                      ],
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'view') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Loan Details'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Amount: ₹${loan.amount}"),
                                  Text("Status: ${loan.status}"),
                                  ...loan.extraData.entries.map((e) => Text("${e.key}: ${e.value}")),
                                ],
                              ),
                            ),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                          ),
                        );
                      } else if (value == 'edit') {
                        if (widget.category == LeadCategory.business) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessLoanForm(userData: {'id': widget.userId}, initialLead: loan))).then((_) => _refresh());
                        } else if (widget.category == LeadCategory.farmer) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => FarmerLoanForm(userData: {'id': widget.userId}, initialLead: loan))).then((_) => _refresh());
                        } else if (widget.category == LeadCategory.student) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EducationLoanForm(userData: {'id': widget.userId}, initialLead: loan))).then((_) => _refresh());
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit / Update')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

bool leadStatusApproved(String status) {
  final s = status.toLowerCase();
  return s == 'approved' || s == 'claimed';
}
