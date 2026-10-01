import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/pulse_models.dart';
import '../../../../core/providers/app_state_providers.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/services/revenuecat_service.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTeamId = ref.watch(currentTeamIdProvider);

    return StreamBuilder<TeamAnalytics>(
      stream: FirestoreService.instance.streamTeamAnalytics(activeTeamId),
      builder: (context, snapshot) {
        final analytics = snapshot.data ?? TeamAnalytics.fromCheckins(activeTeamId, _sampleCheckins(activeTeamId));

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _BurnoutRiskBanner(analytics: analytics)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 20),
                _TeamWellnessScoreCard(analytics: analytics)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 20),
                _WeeklyTrendChart(snapshots: analytics.weeklyTrend)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 20),
                const _MoodBreakdownCard()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 20),
                _QuickActionsRow(context: context, analytics: analytics)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),
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

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good afternoon, Alex 👋',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Team Dashboard',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.15),
            child: Text(
              'A',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryTeal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<PulseCheckin> _sampleCheckins(String teamId) {
    final now = DateTime.now();
    return [
      PulseCheckin(
        anonymousUserId: 'anon1',
        teamId: teamId,
        mood: MoodLevel.good,
        energy: EnergyLevel.high,
        workload: WorkloadLevel.balanced,
        timestamp: now,
      ),
      PulseCheckin(
        anonymousUserId: 'anon2',
        teamId: teamId,
        mood: MoodLevel.stressed,
        energy: EnergyLevel.low,
        workload: WorkloadLevel.heavy,
        timestamp: now,
      ),
      PulseCheckin(
        anonymousUserId: 'anon3',
        teamId: teamId,
        mood: MoodLevel.neutral,
        energy: EnergyLevel.medium,
        workload: WorkloadLevel.balanced,
        timestamp: now,
      ),
    ];
  }
}

class _BurnoutRiskBanner extends StatelessWidget {
  const _BurnoutRiskBanner({required this.analytics});
  final TeamAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final risk = analytics.burnoutRisk;
    final Color bannerColor;
    switch (risk) {
      case BurnoutRisk.critical:
        bannerColor = AppTheme.moodBurntOut;
      case BurnoutRisk.high:
        bannerColor = AppTheme.moodStressed;
      case BurnoutRisk.medium:
        bannerColor = AppTheme.moodNeutral;
      case BurnoutRisk.low:
        bannerColor = AppTheme.moodExcellent;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Text(risk.indicator, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${risk.label} Burnout Risk',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: bannerColor,
                  ),
                ),
                Text(
                  risk.message,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (risk == BurnoutRisk.high || risk == BurnoutRisk.critical)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: bannerColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Act Now',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class _TeamWellnessScoreCard extends StatelessWidget {
  const _TeamWellnessScoreCard({required this.analytics});
  final TeamAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final score = analytics.averageWellnessScore;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Wellness Score',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      score.toStringAsFixed(0),
                      style: GoogleFonts.inter(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '/100',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _ScoreBar(score: score),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatChip(
                      label: 'Check-ins today',
                      value: '${analytics.participationRate}%',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Total',
                      value: '${analytics.totalCheckins}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _WellnessMeter(score: score),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: score / 100,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 6,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _WellnessMeter extends StatelessWidget {
  const _WellnessMeter({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          Text(
            score >= 70 ? '😊' : score >= 40 ? '😐' : '😟',
            style: const TextStyle(fontSize: 30),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTrendChart extends StatelessWidget {
  const _WeeklyTrendChart({required this.snapshots});
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
            Text(
              '7-Day Wellness Trend',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? Colors.white10 : Colors.black12,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt() % 7],
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        snapshots.length,
                        (i) => FlSpot(
                          i.toDouble(),
                          snapshots[i].averageScore == 0
                              ? 50 // Default for missing data
                              : snapshots[i].averageScore,
                        ),
                      ),
                      isCurved: true,
                      color: AppTheme.primaryTeal,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryTeal,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryTeal.withValues(alpha: 0.3),
                            AppTheme.primaryTeal.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodBreakdownCard extends StatelessWidget {
  const _MoodBreakdownCard();

  @override
  Widget build(BuildContext context) {
    final breakdown = {
      MoodLevel.excellent: 15,
      MoodLevel.good: 40,
      MoodLevel.neutral: 25,
      MoodLevel.stressed: 15,
      MoodLevel.burntOut: 5,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Distribution',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...breakdown.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(e.key.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: Text(
                        e.key.label,
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: e.value / 100,
                          backgroundColor: Colors.grey.withValues(alpha: 0.15),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${e.value}%',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.context, required this.analytics});
  final BuildContext context;
  final TeamAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.group_add,
            label: 'Invite Team',
            color: AppTheme.accentPurple,
            onTap: () => context.go('/team/invite'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.picture_as_pdf,
            label: 'Export PDF',
            color: AppTheme.accentAmber,
            onTap: () async {
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
            isPro: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.bar_chart,
            label: 'Analytics',
            color: AppTheme.primaryTeal,
            onTap: () => context.go('/analytics'),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isPro = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (isPro) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PRO',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
