import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:the_digital_registration/controllers/service_controller.dart';
import 'package:the_digital_registration/views/internship_application_screen.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';

/// Screen for Job Seekers to browse all available jobs and apply.
class AvailableJobsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AvailableJobsScreen({super.key, required this.userData});

  @override
  State<AvailableJobsScreen> createState() => _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends State<AvailableJobsScreen> {
  late Future<List<dynamic>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = ServiceController().fetchJobs();
  }

  void _refresh() {
    setState(() {
      _jobsFuture = ServiceController().fetchJobs();
    });
  }

  void _openApplication(dynamic job) {
    if (job is! Map) return;
    final m = Map<String, dynamic>.from(job);
    final idRaw = m['id'];
    if (idRaw == null) return;
    final jobId = int.tryParse(idRaw.toString()) ?? 0;
    if (jobId == 0) return;

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => InternshipApplicationScreen(
          userData: widget.userData,
          jobId: jobId,
          jobTitle: m['job_title']?.toString() ?? 'Job',
          companyName: m['company_name']?.toString() ?? 'Company',
          salaryRange: m['salary_range']?.toString() ?? 'N/A',
          jobDetails: m,
        ),
      ),
    ).then((_) => _refresh());
  }

  void _showJobDetails(Map<String, dynamic> job) {
    Map<String, dynamic> details = {};
    if (job['details'] is Map) {
      details = Map<String, dynamic>.from(job['details']);
    } else if (job['details'] is String) {
      try {
        details = jsonDecode(job['details']);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
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
                    job['job_title']?.toString() ?? 'Job Title',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    job['company_name']?.toString() ?? 'Company',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  _chipRow(Icons.currency_rupee, 'Salary', job['salary_range']?.toString() ?? 'N/A', Colors.green),
                  if (details['job_type'] != null)
                    _chipRow(Icons.work_outline, 'Type', details['job_type'], Colors.blue),
                  if (details['work_mode'] != null)
                    _chipRow(Icons.computer, 'Mode', details['work_mode'], Colors.purple),
                  if (details['location'] != null)
                    _chipRow(Icons.location_on, 'Location', details['location'], Colors.red),
                  if (details['department'] != null)
                    _chipRow(Icons.category, 'Department', details['department'], Colors.teal),
                  if (details['qualification'] != null)
                    _chipRow(Icons.school, 'Education', details['qualification'], Colors.orange),
                  if (details['openings'] != null)
                    _chipRow(Icons.group, 'Openings', details['openings'], Colors.indigo),
                  if (details['application_deadline'] != null)
                    _chipRow(Icons.event, 'Deadline', details['application_deadline'], Colors.red),
                  const SizedBox(height: 16),
                  if ((job['description']?.toString() ?? details['description']?.toString() ?? '').isNotEmpty) ...[
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      job['description']?.toString() ?? details['description']?.toString() ?? '',
                      style: TextStyle(color: Colors.grey.shade800, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if ((details['skills_required']?.toString() ?? '').isNotEmpty) ...[
                    const Text('Skills Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: details['skills_required'].toString().split(',').map<Widget>((s) {
                        return Chip(
                          label: Text(s.trim(), style: const TextStyle(fontSize: 12)),
                          backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if ((details['benefits']?.toString() ?? '').isNotEmpty) ...[
                    const Text('Benefits & Perks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      details['benefits'].toString(),
                      style: TextStyle(color: Colors.grey.shade800, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openApplication(job);
                      },
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('APPLY NOW', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _chipRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Find Jobs',
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
        future: _jobsFuture,
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
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs available right now',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new opportunities!',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          return ResponsiveListView(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final m = job is Map ? Map<String, dynamic>.from(job) : <String, dynamic>{};
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showJobDetails(m),
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
                                color: const Color(0xFF2196F3).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.work_outline, color: Color(0xFF2196F3)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['job_title']?.toString() ?? 'Unknown Title',
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
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                m['salary_range']?.toString() ?? 'N/A',
                                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _openApplication(m),
                              icon: const Icon(Icons.send, size: 16, color: Color(0xFF2196F3)),
                              label: const Text('Apply', style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
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
