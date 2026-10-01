import 'package:uuid/uuid.dart';

/// Mood levels for the pulse check-in
enum MoodLevel {
  excellent(5, '😄', 'Excellent', 'Feeling amazing!'),
  good(4, '🙂', 'Good', 'Doing well'),
  neutral(3, '😐', 'Okay', 'Just alright'),
  stressed(2, '😓', 'Stressed', 'Under pressure'),
  burntOut(1, '😰', 'Burnt Out', 'Really struggling');

  const MoodLevel(this.score, this.emoji, this.label, this.description);
  final int score;
  final String emoji;
  final String label;
  final String description;
}

/// Energy level for the pulse check-in
enum EnergyLevel {
  high(3, '⚡', 'High Energy'),
  medium(2, '🔋', 'Medium'),
  low(1, '🪫', 'Low Energy');

  const EnergyLevel(this.score, this.emoji, this.label);
  final int score;
  final String emoji;
  final String label;
}

/// Workload feeling for the pulse check-in
enum WorkloadLevel {
  light(1, '☁️', 'Light', 'Could handle more'),
  balanced(2, '⚖️', 'Balanced', 'Just right'),
  heavy(3, '🏋️', 'Heavy', 'A lot on my plate'),
  overwhelming(4, '🌊', 'Overwhelming', 'Too much to handle');

  const WorkloadLevel(this.score, this.emoji, this.label, this.description);
  final int score;
  final String emoji;
  final String label;
  final String description;
}

/// A single anonymous pulse check-in entry
class PulseCheckin {
  final String id;
  final String anonymousUserId; // Hashed, never linked to identity
  final String teamId;
  final MoodLevel mood;
  final EnergyLevel energy;
  final WorkloadLevel workload;
  final String? anonymousNote; // Optional free text
  final DateTime timestamp;
  final int wellnessScore; // Computed 0-100

  PulseCheckin({
    String? id,
    required this.anonymousUserId,
    required this.teamId,
    required this.mood,
    required this.energy,
    required this.workload,
    this.anonymousNote,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        wellnessScore = _computeScore(mood, energy, workload);

  static int _computeScore(MoodLevel mood, EnergyLevel energy, WorkloadLevel workload) {
    // Weighted formula: mood 50%, energy 30%, workload 20% (inverted)
    final moodNorm = ((mood.score - 1) / 4) * 100;
    final energyNorm = ((energy.score - 1) / 2) * 100;
    final workloadNorm = ((4 - workload.score) / 3) * 100;
    return ((moodNorm * 0.5) + (energyNorm * 0.3) + (workloadNorm * 0.2)).round();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'anonymousUserId': anonymousUserId,
        'teamId': teamId,
        'mood': mood.name,
        'energy': energy.name,
        'workload': workload.name,
        'anonymousNote': anonymousNote,
        'timestamp': timestamp.toIso8601String(),
        'wellnessScore': wellnessScore,
      };

  factory PulseCheckin.fromJson(Map<String, dynamic> json) => PulseCheckin(
        id: json['id'],
        anonymousUserId: json['anonymousUserId'],
        teamId: json['teamId'],
        mood: MoodLevel.values.byName(json['mood']),
        energy: EnergyLevel.values.byName(json['energy']),
        workload: WorkloadLevel.values.byName(json['workload']),
        anonymousNote: json['anonymousNote'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

/// Team model
class Team {
  final String id;
  final String name;
  final String managerId;
  final List<String> memberIds;
  final String inviteCode;
  final DateTime createdAt;

  const Team({
    required this.id,
    required this.name,
    required this.managerId,
    required this.memberIds,
    required this.inviteCode,
    required this.createdAt,
  });

  int get memberCount => memberIds.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'managerId': managerId,
        'memberIds': memberIds,
        'inviteCode': inviteCode,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'],
        name: json['name'],
        managerId: json['managerId'],
        memberIds: List<String>.from(json['memberIds']),
        inviteCode: json['inviteCode'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

/// Aggregated team analytics
class TeamAnalytics {
  final String teamId;
  final double averageWellnessScore;
  final double averageMoodScore;
  final double averageEnergyScore;
  final double burnoutRiskPercent; // 0-100%
  final int totalCheckins;
  final int participationRate; // % of members who checked in today
  final List<DailySnapshot> weeklyTrend;
  final BurnoutRisk burnoutRisk;
  final DateTime computedAt;

  const TeamAnalytics({
    required this.teamId,
    required this.averageWellnessScore,
    required this.averageMoodScore,
    required this.averageEnergyScore,
    required this.burnoutRiskPercent,
    required this.totalCheckins,
    required this.participationRate,
    required this.weeklyTrend,
    required this.burnoutRisk,
    required this.computedAt,
  });

  factory TeamAnalytics.fromCheckins(String teamId, List<PulseCheckin> checkins) {
    if (checkins.isEmpty) {
      return TeamAnalytics(
        teamId: teamId,
        averageWellnessScore: 0,
        averageMoodScore: 0,
        averageEnergyScore: 0,
        burnoutRiskPercent: 0,
        totalCheckins: 0,
        participationRate: 0,
        weeklyTrend: [],
        burnoutRisk: BurnoutRisk.low,
        computedAt: DateTime.now(),
      );
    }

    final avgWellness = checkins.map((c) => c.wellnessScore).reduce((a, b) => a + b) /
        checkins.length;
    final avgMood =
        checkins.map((c) => c.mood.score).reduce((a, b) => a + b) / checkins.length;
    final avgEnergy =
        checkins.map((c) => c.energy.score).reduce((a, b) => a + b) / checkins.length;

    final burntOutCount =
        checkins.where((c) => c.mood == MoodLevel.burntOut || c.mood == MoodLevel.stressed).length;
    final burnoutRiskPct = (burntOutCount / checkins.length) * 100;

    BurnoutRisk risk;
    if (burnoutRiskPct >= 60) {
      risk = BurnoutRisk.critical;
    } else if (burnoutRiskPct >= 40) {
      risk = BurnoutRisk.high;
    } else if (burnoutRiskPct >= 20) {
      risk = BurnoutRisk.medium;
    } else {
      risk = BurnoutRisk.low;
    }

    return TeamAnalytics(
      teamId: teamId,
      averageWellnessScore: avgWellness,
      averageMoodScore: avgMood,
      averageEnergyScore: avgEnergy,
      burnoutRiskPercent: burnoutRiskPct,
      totalCheckins: checkins.length,
      participationRate: 70, // Placeholder, compute from real team size
      weeklyTrend: _buildWeeklyTrend(checkins),
      burnoutRisk: risk,
      computedAt: DateTime.now(),
    );
  }

  static List<DailySnapshot> _buildWeeklyTrend(List<PulseCheckin> checkins) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayCheckins = checkins.where((c) {
        return c.timestamp.year == day.year &&
            c.timestamp.month == day.month &&
            c.timestamp.day == day.day;
      }).toList();
      final avg = dayCheckins.isEmpty
          ? 0.0
          : dayCheckins.map((c) => c.wellnessScore).reduce((a, b) => a + b) /
              dayCheckins.length;
      return DailySnapshot(date: day, averageScore: avg, checkinCount: dayCheckins.length);
    });
  }
}

class DailySnapshot {
  final DateTime date;
  final double averageScore;
  final int checkinCount;

  const DailySnapshot({
    required this.date,
    required this.averageScore,
    required this.checkinCount,
  });
}

enum BurnoutRisk {
  low('Low', '🟢', 'Team is thriving'),
  medium('Medium', '🟡', 'Some stress detected'),
  high('High', '🟠', 'Consider intervention'),
  critical('Critical', '🔴', 'Immediate action needed');

  const BurnoutRisk(this.label, this.indicator, this.message);
  final String label;
  final String indicator;
  final String message;
}
