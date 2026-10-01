import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/pulse_models.dart';

/// Cloud Firestore service for StaffPulse.
/// Handles anonymous check-in ingestion, real-time team streams, and team management.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _teamsCol =>
      _db.collection('teams');

  CollectionReference<Map<String, dynamic>> _checkinsCol(String teamId) =>
      _teamsCol.doc(teamId).collection('checkins');

  // ─────────────────── Pulse Check-Ins ───────────────────

  /// Submit an anonymous pulse check-in to Cloud Firestore.
  /// The check-in stores NO personally identifiable information (only hashed anonymous ID).
  Future<bool> submitCheckin(PulseCheckin checkin) async {
    try {
      final docRef = _checkinsCol(checkin.teamId).doc(checkin.id);
      await docRef.set({
        'id': checkin.id,
        'anonymousUserId': checkin.anonymousUserId,
        'teamId': checkin.teamId,
        'mood': checkin.mood.name,
        'energy': checkin.energy.name,
        'workload': checkin.workload.name,
        'anonymousNote': checkin.anonymousNote,
        'wellnessScore': checkin.wellnessScore,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAtIso': checkin.timestamp.toIso8601String(),
      });

      debugPrint('FirestoreService: Successfully recorded check-in ${checkin.id} in team ${checkin.teamId}');
      return true;
    } catch (e) {
      debugPrint('FirestoreService: Error submitting check-in: $e');
      // Return false but don't crash app
      return false;
    }
  }

  /// Real-time stream of all pulse check-ins for a given team
  Stream<List<PulseCheckin>> streamTeamCheckins(String teamId) {
    return _checkinsCol(teamId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        DateTime dt;
        if (data['timestamp'] is Timestamp) {
          dt = (data['timestamp'] as Timestamp).toDate();
        } else if (data['createdAtIso'] != null) {
          dt = DateTime.parse(data['createdAtIso']);
        } else {
          dt = DateTime.now();
        }

        return PulseCheckin(
          id: data['id'] ?? doc.id,
          anonymousUserId: data['anonymousUserId'] ?? 'anon',
          teamId: data['teamId'] ?? teamId,
          mood: MoodLevel.values.firstWhere(
            (m) => m.name == data['mood'],
            orElse: () => MoodLevel.good,
          ),
          energy: EnergyLevel.values.firstWhere(
            (e) => e.name == data['energy'],
            orElse: () => EnergyLevel.medium,
          ),
          workload: WorkloadLevel.values.firstWhere(
            (w) => w.name == data['workload'],
            orElse: () => WorkloadLevel.balanced,
          ),
          anonymousNote: data['anonymousNote'],
          timestamp: dt,
        );
      }).toList();
    });
  }

  /// Real-time stream of computed TeamAnalytics for a given team
  Stream<TeamAnalytics> streamTeamAnalytics(String teamId) {
    return streamTeamCheckins(teamId).map((checkins) {
      if (checkins.isEmpty) {
        // Return baseline analytics if team is brand new
        return TeamAnalytics.fromCheckins(teamId, _generateBaselineCheckins(teamId));
      }
      return TeamAnalytics.fromCheckins(teamId, checkins);
    });
  }

  // ─────────────────── Team Management ───────────────────

  /// Create a new team in Cloud Firestore with a unique invite code
  Future<Team> createTeam({
    required String name,
    required String managerId,
  }) async {
    final teamId = const Uuid().v4();
    final inviteCode = _generateInviteCode();

    final team = Team(
      id: teamId,
      name: name,
      managerId: managerId,
      memberIds: [managerId],
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );

    try {
      await _teamsCol.doc(teamId).set(team.toJson());
      debugPrint('FirestoreService: Created team $teamId with code $inviteCode');
    } catch (e) {
      debugPrint('FirestoreService: Error creating team: $e');
    }

    return team;
  }

  /// Join a team using a 6-character invite code
  Future<Team?> joinTeamByCode({
    required String inviteCode,
    required String memberId,
  }) async {
    try {
      final query = await _teamsCol
          .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      final team = Team.fromJson(doc.data());

      if (!team.memberIds.contains(memberId)) {
        await doc.reference.update({
          'memberIds': FieldValue.arrayUnion([memberId]),
        });
      }

      return team;
    } catch (e) {
      debugPrint('FirestoreService: Error joining team: $e');
      return null;
    }
  }

  /// Get a single team by its ID
  Future<Team?> getTeam(String teamId) async {
    try {
      final doc = await _teamsCol.doc(teamId).get();
      if (doc.exists && doc.data() != null) {
        return Team.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('FirestoreService: Error getting team: $e');
    }
    return null;
  }

  /// Real-time stream of a team document
  Stream<Team?> streamTeam(String teamId) {
    return _teamsCol.doc(teamId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Team.fromJson(doc.data()!);
    });
  }

  // ─────────────────── Helpers ───────────────────

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  List<PulseCheckin> _generateBaselineCheckins(String teamId) {
    final now = DateTime.now();
    return [
      PulseCheckin(
        anonymousUserId: 'hash_1',
        teamId: teamId,
        mood: MoodLevel.good,
        energy: EnergyLevel.high,
        workload: WorkloadLevel.balanced,
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      PulseCheckin(
        anonymousUserId: 'hash_2',
        teamId: teamId,
        mood: MoodLevel.neutral,
        energy: EnergyLevel.medium,
        workload: WorkloadLevel.heavy,
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
      PulseCheckin(
        anonymousUserId: 'hash_3',
        teamId: teamId,
        mood: MoodLevel.excellent,
        energy: EnergyLevel.high,
        workload: WorkloadLevel.light,
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
