import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumePdfGenerator {
  static Future<Uint8List> generate(Map<String, dynamic> resumeData) async {
    final pdf = pw.Document();

    final edu = resumeData['education'] as Map<String, String>? ?? {};
    final exp = resumeData['experience'] as Map<String, String>? ?? {};
    final skills = (resumeData['skills'] as String? ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    resumeData['name']?.toString() ?? 'Your Name',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Wrap(
                    spacing: 12,
                    children: [
                      if ((resumeData['email'] ?? '').isNotEmpty)
                        pw.Text('Email: ${resumeData['email']}'),
                      if ((resumeData['phone'] ?? '').isNotEmpty)
                        pw.Text('Phone: ${resumeData['phone']}'),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Wrap(
                    spacing: 12,
                    children: [
                      if ((resumeData['linkedin'] ?? '').isNotEmpty)
                        pw.Text('LinkedIn: ${resumeData['linkedin']}'),
                      if ((resumeData['portfolio'] ?? '').isNotEmpty)
                        pw.Text('Portfolio: ${resumeData['portfolio']}'),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Summary
            if ((resumeData['summary'] ?? '').isNotEmpty) ...[
              _sectionTitle('Professional Summary'),
              pw.Text(resumeData['summary']!, style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 16),
            ],

            // Experience
            if (exp['company']!.isNotEmpty || exp['role']!.isNotEmpty) ...[
              _sectionTitle('Experience'),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      exp['role']!,
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Text(exp['duration']!, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(exp['company']!, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange)),
              pw.SizedBox(height: 6),
              if (exp['description']!.isNotEmpty)
                pw.Text(exp['description']!, style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 16),
            ],

            // Education
            if (edu['institution']!.isNotEmpty || edu['degree']!.isNotEmpty) ...[
              _sectionTitle('Education'),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      edu['institution']!,
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Text(edu['year']!, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(edu['degree']!, style: const pw.TextStyle(fontSize: 13)),
                  if (edu['gpa']!.isNotEmpty)
                    pw.Text('GPA / Score: ${edu['gpa']}', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 16),
            ],

            // Skills
            if (skills.isNotEmpty) ...[
              _sectionTitle('Skills'),
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((s) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(s, style: const pw.TextStyle(fontSize: 12)),
                )).toList(),
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.deepOrange,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 1.5, width: 40, color: PdfColors.deepOrange),
        pw.SizedBox(height: 8),
      ],
    );
  }
}
