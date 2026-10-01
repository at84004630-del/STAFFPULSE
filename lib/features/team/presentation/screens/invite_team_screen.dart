import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class InviteTeamScreen extends StatelessWidget {
  const InviteTeamScreen({super.key});

  static const String _inviteCode = 'PULSE-X7K9M'; // Generated from team ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Team Members')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR / Code card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('🎟️', style: TextStyle(fontSize: 52))
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text(
                    'Your Team Invite Code',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _inviteCode,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: _inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied! 📋')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryTeal,
                    ),
                    icon: const Icon(Icons.copy),
                    label: Text('Copy Code', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 32),

            // Instructions
            Text(
              'How to invite members:',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            ...[
              ('1', 'Share the invite code', 'Send it via Slack, email, or WhatsApp'),
              ('2', 'They download StaffPulse', 'Available on iOS, Android & Samsung Galaxy Store'),
              ('3', 'Enter the team code', 'They join as an anonymous member'),
              ('4', 'Start check-ins!', 'Their responses are immediately anonymized'),
            ]
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              e.value.$1,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.value.$2,
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              Text(
                                e.value.$3,
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 300 + e.key * 80))
                      .slideX(begin: 0.1, end: 0),
                ),

            const SizedBox(height: 24),
            // Share button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    const ClipboardData(
                      text: 'Join our team on StaffPulse! Download the app and enter invite code: PULSE-X7K9M or visit https://staffpulse.app/join?code=PULSE-X7K9M',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📋 Shareable invite message copied to clipboard!'),
                      backgroundColor: AppTheme.primaryTeal,
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Invite Link'),
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 24),
            // Privacy reminder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: AppTheme.accentPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Members who join can only submit anonymous check-ins. They never see other members\' responses.',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, height: 1.4),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
