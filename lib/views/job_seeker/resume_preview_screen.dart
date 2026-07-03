import 'package:flutter/material.dart';
import '../../utils/resume_pdf_generator.dart';
import '../../utils/pdf_downloader.dart';

class ResumePreviewScreen extends StatelessWidget {
  final Map<String, dynamic> resumeData;
  const ResumePreviewScreen({super.key, required this.resumeData});

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 2, width: 40, color: const Color(0xFF2196F3)),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final pdfBytes = await ResumePdfGenerator.generate(resumeData);
      final name = (resumeData['name']?.toString() ?? 'resume').replaceAll(' ', '_');
      await downloadPdf(pdfBytes, '${name}_resume.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final edu = resumeData['education'] as Map<String, String>? ?? {};
    final exp = resumeData['experience'] as Map<String, String>? ?? {};
    final skills = (resumeData['skills'] as String? ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text('Resume Preview', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF2196F3)),
            tooltip: 'Download PDF',
            onPressed: () => _downloadPdf(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        resumeData['name']?.toString() ?? 'Your Name',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        children: [
                          if ((resumeData['email'] ?? '').isNotEmpty)
                            _iconText(Icons.email, resumeData['email']!),
                          if ((resumeData['phone'] ?? '').isNotEmpty)
                            _iconText(Icons.phone, resumeData['phone']!),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        children: [
                          if ((resumeData['linkedin'] ?? '').isNotEmpty)
                            _iconText(Icons.link, resumeData['linkedin']!),
                          if ((resumeData['portfolio'] ?? '').isNotEmpty)
                            _iconText(Icons.language, resumeData['portfolio']!),
                        ],
                      ),
                    ],
                  ),
                ),

                // Summary
                if ((resumeData['summary'] ?? '').isNotEmpty) ...[
                  _sectionTitle('Professional Summary'),
                  Text(
                    resumeData['summary']!,
                    style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade800),
                  ),
                ],

                // Experience
                if (exp['company']!.isNotEmpty || exp['role']!.isNotEmpty) ...[
                  _sectionTitle('Experience'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exp['role']!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        exp['duration']!,
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exp['company']!,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2196F3)),
                  ),
                  const SizedBox(height: 8),
                  if (exp['description']!.isNotEmpty)
                    Text(
                      exp['description']!,
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade800),
                    ),
                ],

                // Education
                if (edu['institution']!.isNotEmpty || edu['degree']!.isNotEmpty) ...[
                  _sectionTitle('Education'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          edu['institution']!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        edu['year']!,
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        edu['degree']!,
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                      ),
                      if (edu['gpa']!.isNotEmpty)
                        Text(
                          'GPA / Score: ${edu['gpa']}',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        ),
                    ],
                  ),
                ],

                // Skills
                if (skills.isNotEmpty) ...[
                  _sectionTitle('Skills'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
      ],
    );
  }
}
