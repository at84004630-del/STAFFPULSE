import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/pulse_models.dart';

class PdfExportService {
  PdfExportService._();
  static final PdfExportService instance = PdfExportService._();

  /// Generate and present the StaffPulse Team Wellness Report
  Future<void> exportWellnessReport({
    required BuildContext context,
    required TeamAnalytics analytics,
    String teamName = 'Engineering & Product Team',
  }) async {
    final pdfBytes = await generateReportBytes(
      analytics: analytics,
      teamName: teamName,
    );

    final fileName = 'StaffPulse_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: fileName,
    );
  }

  /// Generate raw PDF bytes
  Future<Uint8List> generateReportBytes({
    required TeamAnalytics analytics,
    String teamName = 'Engineering & Product Team',
  }) async {
    final doc = pw.Document(
      title: 'StaffPulse Team Wellness & Burnout Risk Executive Report',
      author: 'StaffPulse AI Analytics',
    );

    final now = DateTime.now();
    final dateStr = DateFormat('MMMM d, yyyy').format(now);
    final primaryTeal = PdfColor.fromHex('#00BFA6');
    final darkTeal = PdfColor.fromHex('#006B5E');
    final darkSlate = PdfColor.fromHex('#1A2235');
    final lightGrey = PdfColor.fromHex('#F5F7FA');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: primaryTeal,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'StaffPulse Pro Report',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Team Wellness & Burnout Risk Executive Summary',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          dateStr,
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          teamName,
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // KPI Row
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildMetricTile(
                      label: 'Avg. Wellness Score',
                      value: '${analytics.averageWellnessScore.toStringAsFixed(0)} / 100',
                      subtext: analytics.averageWellnessScore >= 70
                          ? 'Healthy range'
                          : 'Action recommended',
                      borderColor: primaryTeal,
                      bgColor: lightGrey,
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: _buildMetricTile(
                      label: 'Burnout Risk',
                      value: '${analytics.burnoutRiskPercent.toStringAsFixed(0)}%',
                      subtext: 'Status: ${analytics.burnoutRisk.name.toUpperCase()}',
                      borderColor: analytics.burnoutRiskPercent > 40
                          ? PdfColors.redAccent
                          : PdfColors.green,
                      bgColor: lightGrey,
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: _buildMetricTile(
                      label: 'Participation Rate',
                      value: '${analytics.participationRate}%',
                      subtext: '${analytics.totalCheckins} check-ins recorded',
                      borderColor: darkTeal,
                      bgColor: lightGrey,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Burnout Risk Analysis Section
              pw.Text(
                'Executive Risk Assessment',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: darkSlate,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: lightGrey,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      analytics.burnoutRiskPercent > 40
                          ? 'ALERT: Team burnout risk is elevated. ${analytics.burnoutRiskPercent.toStringAsFixed(0)}% of submitted check-ins indicate heavy stress or overwhelming workloads. Immediate manager intervention is advised.'
                          : 'STATUS STABLE: Team wellness is operating within safe parameters. Continue maintaining healthy workload balances and daily anonymous pulse monitoring.',
                      style: pw.TextStyle(fontSize: 11, height: 1.4, color: darkSlate),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Privacy Assurance: Responses are aggregated across 100% anonymous rotating tokens. Individual employee identities are cryptographically unlinked to preserve psychological safety.',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Recommended Manager Action Plan
              pw.Text(
                'Recommended Action Plan',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: darkSlate,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildActionItem(
                number: '1',
                title: 'Check in on Workload Bottlenecks',
                desc: 'Review upcoming sprint deliverables and distribute non-critical tasks.',
              ),
              pw.SizedBox(height: 8),
              _buildActionItem(
                number: '2',
                title: 'Schedule No-Meeting Focus Blocks',
                desc: 'Give team members dedicated heads-down time to reduce context-switching anxiety.',
              ),
              pw.SizedBox(height: 8),
              _buildActionItem(
                number: '3',
                title: 'Acknowledge Psychological Safety in Next Standup',
                desc: 'Remind team members that StaffPulse check-ins are 100% anonymous and valued.',
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'StaffPulse Pro — Powered by RevenueCat & Firebase',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Confidential Internal Document',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    required PdfColor borderColor,
    required PdfColor bgColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: borderColor, width: 1.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            subtext,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildActionItem({
    required String number,
    required String title,
    required String desc,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 20,
          height: 20,
          decoration: const pw.BoxDecoration(
            color: PdfColors.teal,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(
              number,
              style: const pw.TextStyle(
                color: PdfColors.white,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                desc,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
