import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/pulse_models.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  final bool hasCheckedInToday;
  const EmployeeDashboardScreen({super.key, this.hasCheckedInToday = false});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lastCheckin = PulseCheckin(
      anonymousUserId: 'self',
      teamId: 'team1',
      mood: MoodLevel.good,
      energy: EnergyLevel.medium,
      workload: WorkloadLevel.balanced,
      timestamp: now.subtract(const Duration(days: 1)),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            snap: true,
            pinned: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Sam 🌟',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  'My Wellbeing',
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Daily check-in prompt card
                if (!hasCheckedInToday) ...[
                  _CheckInPromptCard()
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 20),
                ] else ...[
                  _AlreadyCheckedInCard(checkin: lastCheckin)
                      .animate()
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),
                ],

                // Personal wellbeing history
                _PersonalScoreCard(lastCheckin: lastCheckin)
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms),
                const SizedBox(height: 20),

                // Wellbeing tips
                _WellbeingTipsCard()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 20),

                // Privacy reminder
                _PrivacyBadge()
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 400.ms),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInPromptCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/pulse-checkin'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('💚', style: TextStyle(fontSize: 40)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Today',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'How are you feeling\ntoday?',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anonymous • Takes 10 seconds • Helps your team',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: MoodLevel.values.map((mood) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mood.emoji,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Icon(Icons.touch_app, color: Colors.white60, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlreadyCheckedInCard extends StatelessWidget {
  const _AlreadyCheckedInCard({required this.checkin});
  final PulseCheckin checkin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.moodGood.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.moodGood.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'ve checked in today!',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.moodGood,
                  ),
                ),
                Text(
                  'Your response was recorded anonymously. Come back tomorrow.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalScoreCard extends StatelessWidget {
  const _PersonalScoreCard({required this.lastCheckin});
  final PulseCheckin lastCheckin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Last Check-in',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Yesterday',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _MoodBadge(label: 'Mood', emoji: lastCheckin.mood.emoji, value: lastCheckin.mood.label),
                const SizedBox(width: 12),
                _MoodBadge(label: 'Energy', emoji: lastCheckin.energy.emoji, value: lastCheckin.energy.label),
                const SizedBox(width: 12),
                _MoodBadge(label: 'Workload', emoji: lastCheckin.workload.emoji, value: lastCheckin.workload.label),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wellness Score',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${lastCheckin.wellnessScore}/100',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTeal,
                    ),
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

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({
    required this.label,
    required this.emoji,
    required this.value,
  });
  final String label;
  final String emoji;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkCard
              : AppTheme.lightBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WellbeingTipsCard extends StatelessWidget {
  final List<Map<String, String>> _tips = [
    {'emoji': '🧘', 'tip': 'Take a 5-min breathing break between meetings'},
    {'emoji': '🚶', 'tip': 'A short walk boosts focus by up to 60%'},
    {'emoji': '💧', 'tip': 'Stay hydrated — aim for 8 glasses today'},
    {'emoji': '🎵', 'tip': 'Music can reduce workplace stress by 65%'},
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[DateTime.now().day % _tips.length];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(tip['emoji']!, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wellbeing Tip',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    tip['tip']!,
                    style: GoogleFonts.inter(fontSize: 14, height: 1.4),
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

class _PrivacyBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: AppTheme.accentPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '🔒 Your responses are 100% anonymous. Managers only see aggregated team data.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
