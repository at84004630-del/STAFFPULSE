import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/pulse_models.dart';
import '../../../../core/providers/app_state_providers.dart';
import '../../../../core/services/firestore_service.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTeamId = ref.watch(currentTeamIdProvider);

    return StreamBuilder<List<PulseCheckin>>(
      stream: FirestoreService.instance.streamTeamCheckins(activeTeamId),
      builder: (context, snapshot) {
        final checkins = snapshot.data ?? [];
        const totalMembers = 3;
        final checkedInCount = checkins.isEmpty ? 2 : checkins.length.clamp(0, totalMembers);
        final avgScore = checkins.isEmpty
            ? 72
            : (checkins.map((c) => c.wellnessScore).reduce((a, b) => a + b) / checkins.length).round();

        final memberItems = [
          {'name': 'Anonymous Member #1', 'checkedIn': true, 'score': checkins.isNotEmpty ? checkins[0].wellnessScore : 72},
          {'name': 'Anonymous Member #2', 'checkedIn': checkedInCount >= 2, 'score': checkins.length > 1 ? checkins[1].wellnessScore : 65},
          {'name': 'Anonymous Member #3', 'checkedIn': checkedInCount >= 3, 'score': checkins.length > 2 ? checkins[2].wellnessScore : null},
        ];

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                floating: true,
                snap: true,
                title: Text(
                  'My Team',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 22),
                ),
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/team/invite'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Invite'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Team stats overview
                    _TeamStatsRow(
                      totalMembers: totalMembers,
                      checkedInCount: checkedInCount,
                      avgScore: avgScore,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 24),

                    // Today's participation
                    Text(
                      'Today\'s Check-ins',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ...memberItems.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MemberCard(member: e.value, index: e.key)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: e.key * 100))
                            .slideX(begin: 0.1, end: 0),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Free tier upgrade prompt (max 3 members)
                    _FreeTeamLimitBanner()
                        .animate()
                        .fadeIn(delay: 400.ms),
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
}

class _TeamStatsRow extends StatelessWidget {
  const _TeamStatsRow({
    required this.totalMembers,
    required this.checkedInCount,
    required this.avgScore,
  });

  final int totalMembers;
  final int checkedInCount;
  final int avgScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(emoji: '👥', value: '$totalMembers', label: 'Members', color: AppTheme.primaryTeal),
        const SizedBox(width: 12),
        _StatCard(emoji: '📝', value: '$checkedInCount/$totalMembers', label: 'Checked In', color: AppTheme.accentGreen),
        const SizedBox(width: 12),
        _StatCard(emoji: '💚', value: '$avgScore%', label: 'Wellness', color: AppTheme.accentAmber),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });
  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.index});
  final Map<String, dynamic> member;
  final int index;

  @override
  Widget build(BuildContext context) {
    final checkedIn = member['checkedIn'] as bool;
    final score = member['score'] as int?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.15),
              child: const Text(
                '👤',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member['name'] as String,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  Text(
                    checkedIn ? 'Checked in today' : 'Pending check-in',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: checkedIn ? AppTheme.moodGood : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (checkedIn && score != null) ...[
              Column(
                children: [
                  Text(
                    '$score',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: score >= 60
                          ? AppTheme.moodGood
                          : score >= 40
                              ? AppTheme.moodNeutral
                              : AppTheme.moodBurntOut,
                    ),
                  ),
                  Text('/100', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pending',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FreeTeamLimitBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/paywall'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Text('🔓', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free Plan: 3 Members Max',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Upgrade to Pro for unlimited team members, AI insights & PDF reports.',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
