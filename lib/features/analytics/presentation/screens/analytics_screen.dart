import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/pulse_models.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/services/revenuecat_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TeamAnalytics>(
      stream: FirestoreService.instance.streamTeamAnalytics('team_engineering'),
      builder: (context, snapshot) {
        final analytics = snapshot.data ?? TeamAnalytics.fromCheckins('team_engineering', _sampleCheckins());

        return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(
              'Analytics',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () async {
                  final isPro = await RevenueCatService.instance.isProUser();
                  if (!context.mounted) return;
                  if (isPro) {
                    await PdfExportService.instance.exportWellnessReport(
                      context: context,
                      analytics: analytics,
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Row(
                          children: [
                            const Text('⚡ '),
                            Text('Export PDF Report', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        content: Text(
                          'Executive PDF Reports with burnout trends & recommended manager action plans are a StaffPulse Pro feature.\n\nWould you like to unlock Pro or generate a sample preview?',
                          style: GoogleFonts.inter(fontSize: 13, height: 1.4),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await PdfExportService.instance.exportWellnessReport(
                                context: context,
                                analytics: analytics,
                              );
                            },
                            child: const Text('Preview Sample PDF'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              context.go('/paywall');
                            },
                            child: const Text('Upgrade to Pro'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                tooltip: 'Export PDF (Pro)',
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Summary cards row
                _SummaryCardsRow(analytics: analytics)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),

                // 7-day wellness chart
                _LargeWellnessChart(snapshots: analytics.weeklyTrend)
                    .animate()
                    .fadeIn(delay: 150.ms),
                const SizedBox(height: 24),

                // Mood distribution pie
                _MoodPieChart()
                    .animate()
                    .fadeIn(delay: 300.ms),
                const SizedBox(height: 24),

                // Workload heatmap
                _WorkloadCard()
                    .animate()
                    .fadeIn(delay: 450.ms),
                const SizedBox(height: 24),

                // Pro gate for detailed analytics
                _ProAnalyticsBanner()
                    .animate()
                    .fadeIn(delay: 600.ms),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  },
);
}

  List<PulseCheckin> _sampleCheckins() {
    final now = DateTime.now();
    return List.generate(10, (i) => PulseCheckin(
      anonymousUserId: 'anon$i',
      teamId: 'team1',
      mood: MoodLevel.values[i % 5],
      energy: EnergyLevel.values[i % 3],
      workload: WorkloadLevel.values[i % 4],
      timestamp: now.subtract(Duration(days: i ~/ 2)),
    ));
  }
}

class _SummaryCardsRow extends StatelessWidget {
  const _SummaryCardsRow({required this.analytics});
  final TeamAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Avg. Wellness',
            value: analytics.averageWellnessScore.toStringAsFixed(0),
            unit: '/100',
            color: AppTheme.primaryTeal,
            emoji: '💚',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Burnout Risk',
            value: '${analytics.burnoutRiskPercent.toStringAsFixed(0)}%',
            unit: '',
            color: analytics.burnoutRiskPercent > 40
                ? AppTheme.moodBurntOut
                : AppTheme.moodExcellent,
            emoji: analytics.burnoutRisk.indicator,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Participation',
            value: '${analytics.participationRate}%',
            unit: '',
            color: AppTheme.accentPurple,
            emoji: '📊',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.emoji,
  });
  final String label;
  final String value;
  final String unit;
  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            '$value$unit',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LargeWellnessChart extends StatelessWidget {
  const _LargeWellnessChart({required this.snapshots});
  final List<DailySnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Wellness Trend',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Last 7 days',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppTheme.primaryTeal,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt() % 7],
                              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, m) => Text(
                          '${v.toInt()}',
                          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: isDark ? Colors.white10 : Colors.black12,
                      strokeWidth: 1,
                    ),
                  ),
                  barGroups: List.generate(
                    snapshots.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: snapshots[i].averageScore == 0 ? 50 : snapshots[i].averageScore,
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.primaryTeal,
                              AppTheme.primaryTealLight,
                            ],
                          ),
                          width: 28,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood Distribution',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 15,
                            color: AppTheme.moodExcellent,
                            title: '15%',
                            radius: 55,
                            titleStyle: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          PieChartSectionData(
                            value: 40,
                            color: AppTheme.moodGood,
                            title: '40%',
                            radius: 55,
                            titleStyle: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          PieChartSectionData(
                            value: 25,
                            color: AppTheme.moodNeutral,
                            title: '25%',
                            radius: 55,
                            titleStyle: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          PieChartSectionData(
                            value: 15,
                            color: AppTheme.moodStressed,
                            title: '15%',
                            radius: 55,
                            titleStyle: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          PieChartSectionData(
                            value: 5,
                            color: AppTheme.moodBurntOut,
                            title: '5%',
                            radius: 55,
                            titleStyle: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: MoodLevel.values.map((m) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(
                            color: [AppTheme.moodExcellent, AppTheme.moodGood, AppTheme.moodNeutral, AppTheme.moodStressed, AppTheme.moodBurntOut][MoodLevel.values.indexOf(m)],
                            shape: BoxShape.circle,
                          )),
                          const SizedBox(width: 6),
                          Text('${m.emoji} ${m.label}', style: GoogleFonts.inter(fontSize: 11)),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkloadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workload Distribution',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...WorkloadLevel.values.map((w) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(w.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(width: 100, child: Text(w.label, style: GoogleFonts.inter(fontSize: 13))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: [0.1, 0.45, 0.35, 0.1][WorkloadLevel.values.indexOf(w)],
                        minHeight: 10,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ProAnalyticsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/paywall'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.accentPurple.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Text('🔒', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('30-Day History & AI Predictions',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.accentPurple)),
                  Text('Unlock with Pro for deeper team insights and burnout prediction AI.',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('PRO', style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
