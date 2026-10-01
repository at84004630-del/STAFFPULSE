import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class PulseResultsScreen extends StatelessWidget {
  const PulseResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.wellnessGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('✅', style: TextStyle(fontSize: 52)),
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.3, 0.3), duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              Text(
                'Check-in Complete!',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 12),
              Text(
                'Your response has been recorded anonymously.\nYour team thanks you! 💚',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 40),

              // Stats cards
              const Row(
                children: [
                  _ResultStat(
                    emoji: '🔒',
                    label: 'Anonymized',
                    value: '100%',
                    color: AppTheme.accentPurple,
                  ),
                  SizedBox(width: 12),
                  _ResultStat(
                    emoji: '📊',
                    label: 'Contributing to',
                    value: 'Team Score',
                    color: AppTheme.primaryTeal,
                  ),
                  SizedBox(width: 12),
                  _ResultStat(
                    emoji: '🔔',
                    label: 'Next check-in',
                    value: 'Tomorrow',
                    color: AppTheme.accentAmber,
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 40),

              // Motivational message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '"Workplaces where people feel psychologically safe see 27% lower turnover and 76% more engagement."\n\n— Harvard Business Review',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ).animate().fadeIn(delay: 750.ms),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/employee'),
                  child: const Text('Back to Dashboard'),
                ),
              ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });
  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
