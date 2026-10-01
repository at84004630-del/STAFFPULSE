import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/pulse_models.dart';
import '../../../../core/providers/app_state_providers.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';

class PulseCheckinScreen extends ConsumerStatefulWidget {
  const PulseCheckinScreen({super.key});

  @override
  ConsumerState<PulseCheckinScreen> createState() => _PulseCheckinScreenState();
}

class _PulseCheckinScreenState extends ConsumerState<PulseCheckinScreen> {
  int _step = 0;
  MoodLevel? _selectedMood;
  EnergyLevel? _selectedEnergy;
  WorkloadLevel? _selectedWorkload;
  final _noteController = TextEditingController();

  final List<String> _stepTitles = [
    'How are you feeling?',
    'What\'s your energy like?',
    'How\'s your workload?',
    'Anything to share?',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 3) {
      HapticFeedback.lightImpact();
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _selectedMood != null;
      case 1:
        return _selectedEnergy != null;
      case 2:
        return _selectedWorkload != null;
      case 3:
        return true; // Note is optional
      default:
        return false;
    }
  }

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final userId = AuthService.instance.currentUserId ?? 'anon_${DateTime.now().millisecondsSinceEpoch}';
      final activeTeamId = ref.read(currentTeamIdProvider);
      final checkin = PulseCheckin(
        anonymousUserId: userId,
        teamId: activeTeamId,
        mood: _selectedMood!,
        energy: _selectedEnergy!,
        workload: _selectedWorkload!,
        anonymousNote: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      await FirestoreService.instance.submitCheckin(checkin);
    } catch (e) {
      debugPrint('Error saving check-in to Firestore: $e');
    }

    if (mounted) {
      context.go('/pulse-results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _buildCurrentStep(),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousStep,
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '🔒 Anonymous Check-in',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _stepTitles[_step],
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 5,
                decoration: BoxDecoration(
                  color: i <= _step
                      ? AppTheme.primaryTeal
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_step) {
      0 => _MoodStep(
          key: const ValueKey(0),
          selected: _selectedMood,
          onSelect: (mood) => setState(() => _selectedMood = mood),
        ),
      1 => _EnergyStep(
          key: const ValueKey(1),
          selected: _selectedEnergy,
          onSelect: (energy) => setState(() => _selectedEnergy = energy),
        ),
      2 => _WorkloadStep(
          key: const ValueKey(2),
          selected: _selectedWorkload,
          onSelect: (workload) => setState(() => _selectedWorkload = workload),
        ),
      3 => _NoteStep(
          key: const ValueKey(3),
          controller: _noteController,
        ),
      _ => const SizedBox(),
    };
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
        top: 16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canProceed ? _nextStep : null,
          child: Text(_step == 3 ? '✅ Submit Anonymously' : 'Continue →'),
        ),
      ),
    );
  }
}

// ─────────────────── Step 0: Mood ───────────────────

class _MoodStep extends StatelessWidget {
  const _MoodStep({super.key, required this.selected, required this.onSelect});
  final MoodLevel? selected;
  final ValueChanged<MoodLevel> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            'Tap the emoji that best describes how you feel right now',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ...MoodLevel.values.map((mood) {
            final isSelected = selected == mood;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(mood);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                        : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Text(
                        mood.emoji,
                        style: TextStyle(fontSize: isSelected ? 36 : 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mood.label,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: isSelected ? AppTheme.primaryTeal : null,
                              ),
                            ),
                            Text(
                              mood.description,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppTheme.primaryTeal)
                          .animate()
                          .scale(duration: 200.ms),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: MoodLevel.values.indexOf(mood) * 60))
                  .slideX(begin: 0.1, end: 0),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────── Step 1: Energy ───────────────────

class _EnergyStep extends StatelessWidget {
  const _EnergyStep({super.key, required this.selected, required this.onSelect});
  final EnergyLevel? selected;
  final ValueChanged<EnergyLevel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            'What best describes your energy level today?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 40),
          Row(
            children: EnergyLevel.values.map((energy) {
              final isSelected = selected == energy;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelect(energy);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                            : Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            energy.emoji,
                            style: TextStyle(fontSize: isSelected ? 40 : 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            energy.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isSelected ? AppTheme.primaryTeal : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Step 2: Workload ───────────────────

class _WorkloadStep extends StatelessWidget {
  const _WorkloadStep({super.key, required this.selected, required this.onSelect});
  final WorkloadLevel? selected;
  final ValueChanged<WorkloadLevel> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            'How does your workload feel today?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ...WorkloadLevel.values.map((workload) {
            final isSelected = selected == workload;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(workload);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                        : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(workload.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workload.label,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppTheme.primaryTeal : null,
                              ),
                            ),
                            Text(
                              workload.description,
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppTheme.primaryTeal),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────── Step 3: Optional Note ───────────────────

class _NoteStep extends StatelessWidget {
  const _NoteStep({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Want to share anything? (Optional)',
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield, color: AppTheme.accentPurple, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your note is 100% anonymous. Your name is never stored.',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            maxLines: 6,
            maxLength: 280,
            decoration: InputDecoration(
              hintText: 'e.g., "Dealing with a tight deadline this week..." or skip if nothing to add.',
              hintStyle: GoogleFonts.inter(color: Colors.grey.withValues(alpha: 0.7), fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Common sentiments (tap to add):',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Tight deadline 📅',
              'Need clearer direction 🗺️',
              'Team is great! 🙌',
              'Meeting overload 📆',
              'Could use more support 🤝',
            ].map((s) {
              return GestureDetector(
                onTap: () {
                  controller.text = s.replaceAll(RegExp(r' [^\w\s]'), '');
                },
                child: Chip(
                  label: Text(s, style: GoogleFonts.inter(fontSize: 12)),
                  backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.08),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
