import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:the_digital_registration/controllers/service_controller.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';

/// Screen for Job Seekers to view the status of their submitted job applications.
class MyApplicationsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MyApplicationsScreen({super.key, required this.userData});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late Future<List<dynamic>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    final userId = int.tryParse(widget.userData['id']?.toString() ?? '') ?? 0;
    _applicationsFuture = ServiceController().fetchMyJobApplications(userId);
  }

  void _refresh() {
    setState(() {
      _loadApplications();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return Colors.green;
      case 'rejected':
      case 'declined':
        return Colors.red;
      case 'reviewed':
      case 'in review':
        return Colors.blue;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
      case 'declined':
        return Icons.cancel;
      case 'reviewed':
      case 'in review':
        return Icons.visibility;
      case 'pending':
      default:
        return Icons.hourglass_empty;
    }
  }

  void _showApplicationDetails(Map<String, dynamic> app) {
    Map<String, dynamic> details = {};
    if (app['details'] is Map) {
      details = Map<String, dynamic>.from(app['details']);
    } else if (app['details'] is String && app['details'] != null) {
      try {
        final decoded = jsonDecode(app['details']);
        if (decoded is Map) {
          details = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final status = app['status']?.toString() ?? 'Pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (ctx, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    app['job_title']?.toString() ?? 'Job Title',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app['company_name']?.toString() ?? 'Company',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(status), color: _statusColor(status), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Status: $status',
                          style: TextStyle(
                            color: _statusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (app['salary_range'] != null) ...[
                    _infoRow(Icons.currency_rupee, 'Salary Range', app['salary_range'].toString()),
                  ],
                  if (app['created_at'] != null) ...[
                    _infoRow(Icons.calendar_today, 'Applied On', _formatDate(app['created_at'].toString())),
                  ],
                  if (app['job_description'] != null && app['job_description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Job Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      app['job_description'].toString(),
                      style: TextStyle(color: Colors.grey.shade800, height: 1.5),
                    ),
                  ],
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Your Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (details['cover_letter'] != null) ...[
                      Text('Cover Letter:', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(details['cover_letter'].toString(), style: TextStyle(color: Colors.grey.shade800, height: 1.4)),
                      const SizedBox(height: 12),
                    ],
                    if (details['skills'] != null) ...[
                      Text('Skills:', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(details['skills'].toString(), style: TextStyle(color: Colors.grey.shade800)),
                      const SizedBox(height: 12),
                    ],
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Applications',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final apps = snapshot.data ?? [];
          if (apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start applying for jobs to see your applications here!',
                    style: TextStyle(color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ResponsiveListView(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              final m = app is Map ? Map<String, dynamic>.from(app) : <String, dynamic>{};
              final status = m['status']?.toString() ?? 'Pending';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showApplicationDetails(m),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_statusIcon(status), color: _statusColor(status)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['job_title']?.toString() ?? 'Unknown Job',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    m['company_name']?.toString() ?? 'Unknown Company',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (m['created_at'] != null)
                              Text(
                                _formatDate(m['created_at'].toString()),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                          ],
                        ),
                      ],
                    ),
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
