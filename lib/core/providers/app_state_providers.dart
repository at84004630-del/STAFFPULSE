import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pulse_models.dart';
import '../services/firestore_service.dart';
import '../services/revenuecat_service.dart';

/// Active team ID for the current session
final currentTeamIdProvider = StateProvider<String>((ref) {
  return 'team_engineering';
});

/// Stream of current team metadata
final currentTeamStreamProvider = StreamProvider<Team?>((ref) {
  final teamId = ref.watch(currentTeamIdProvider);
  return FirestoreService.instance.streamTeam(teamId);
});

/// Stream of real-time team analytics
final teamAnalyticsStreamProvider = StreamProvider<TeamAnalytics>((ref) {
  final teamId = ref.watch(currentTeamIdProvider);
  return FirestoreService.instance.streamTeamAnalytics(teamId);
});

/// Stream of recent team check-ins
final teamCheckinsStreamProvider = StreamProvider<List<PulseCheckin>>((ref) {
  final teamId = ref.watch(currentTeamIdProvider);
  return FirestoreService.instance.streamTeamCheckins(teamId);
});

/// Provider for RevenueCat Pro subscription status
final isProUserProvider = FutureProvider<bool>((ref) async {
  return await RevenueCatService.instance.isProUser();
});
