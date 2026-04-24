import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../ui/tokens.dart';

class AppSettings {
  final int pollIntervalSeconds;
  final bool notifyOnNewIncident;
  final bool notifyOnComponentChange;
  final bool notifyOnResolved;
  final GitHubRegion githubRegion;
  final AppThemeMode themeMode;
  final AppTextScale textScale;
  final Map<String, Set<String>> hiddenComponentIds;

  const AppSettings({
    required this.pollIntervalSeconds,
    required this.notifyOnNewIncident,
    required this.notifyOnComponentChange,
    required this.notifyOnResolved,
    required this.githubRegion,
    required this.themeMode,
    required this.textScale,
    required this.hiddenComponentIds,
  });

  const AppSettings.defaults()
    : pollIntervalSeconds = defaultPollIntervalSeconds,
      notifyOnNewIncident = true,
      notifyOnComponentChange = true,
      notifyOnResolved = true,
      githubRegion = defaultGitHubRegion,
      themeMode = AppThemeMode.dark,
      textScale = AppTextScale.medium,
      hiddenComponentIds = const <String, Set<String>>{};

  AppSettings copyWith({
    int? pollIntervalSeconds,
    bool? notifyOnNewIncident,
    bool? notifyOnComponentChange,
    bool? notifyOnResolved,
    GitHubRegion? githubRegion,
    AppThemeMode? themeMode,
    AppTextScale? textScale,
    Map<String, Set<String>>? hiddenComponentIds,
  }) {
    return AppSettings(
      pollIntervalSeconds: pollIntervalSeconds ?? this.pollIntervalSeconds,
      notifyOnNewIncident: notifyOnNewIncident ?? this.notifyOnNewIncident,
      notifyOnComponentChange:
          notifyOnComponentChange ?? this.notifyOnComponentChange,
      notifyOnResolved: notifyOnResolved ?? this.notifyOnResolved,
      githubRegion: githubRegion ?? this.githubRegion,
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      hiddenComponentIds: hiddenComponentIds ?? this.hiddenComponentIds,
    );
  }

  Set<String> hiddenIdsFor(String providerId) =>
      hiddenComponentIds[providerId] ?? const <String>{};
}

class SettingsStore {
  static const _kPollInterval = 'poll_interval_seconds';
  static const _kNotifyNewIncident = 'notify_new_incident';
  static const _kNotifyComponentChange = 'notify_component_change';
  static const _kNotifyResolved = 'notify_resolved';
  static const _kSeenIncidentIds = 'seen_incident_ids';
  static const _kGitHubRegion = 'github_region';
  static const _kThemeMode = 'theme_mode';
  static const _kTextScale = 'text_scale';
  static const _kHiddenProviders = 'hidden_components_providers';
  static const _kHiddenPrefix = 'hidden_components_';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    var interval = prefs.getInt(_kPollInterval) ?? defaultPollIntervalSeconds;
    if (!pollIntervalChoices.contains(interval)) {
      interval = defaultPollIntervalSeconds;
    }
    final providerIds =
        prefs.getStringList(_kHiddenProviders) ?? const <String>[];
    final hidden = <String, Set<String>>{};
    for (final pid in providerIds) {
      final list = prefs.getStringList('$_kHiddenPrefix$pid');
      if (list != null && list.isNotEmpty) {
        hidden[pid] = list.toSet();
      }
    }
    return AppSettings(
      pollIntervalSeconds: interval,
      notifyOnNewIncident: prefs.getBool(_kNotifyNewIncident) ?? true,
      notifyOnComponentChange: prefs.getBool(_kNotifyComponentChange) ?? true,
      notifyOnResolved: prefs.getBool(_kNotifyResolved) ?? true,
      githubRegion: GitHubRegion.fromId(prefs.getString(_kGitHubRegion)),
      themeMode: AppThemeMode.fromId(prefs.getString(_kThemeMode)),
      textScale: AppTextScale.fromId(prefs.getString(_kTextScale)),
      hiddenComponentIds: hidden,
    );
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPollInterval, s.pollIntervalSeconds);
    await prefs.setBool(_kNotifyNewIncident, s.notifyOnNewIncident);
    await prefs.setBool(_kNotifyComponentChange, s.notifyOnComponentChange);
    await prefs.setBool(_kNotifyResolved, s.notifyOnResolved);
    await prefs.setString(_kGitHubRegion, s.githubRegion.id);
    await prefs.setString(_kThemeMode, s.themeMode.id);
    await prefs.setString(_kTextScale, s.textScale.id);

    final previousProviders =
        (prefs.getStringList(_kHiddenProviders) ?? const <String>[]).toSet();
    final nextProviders = s.hiddenComponentIds.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key)
        .toSet();
    for (final stale in previousProviders.difference(nextProviders)) {
      await prefs.remove('$_kHiddenPrefix$stale');
    }
    for (final pid in nextProviders) {
      await prefs.setStringList(
        '$_kHiddenPrefix$pid',
        s.hiddenComponentIds[pid]!.toList(),
      );
    }
    await prefs.setStringList(_kHiddenProviders, nextProviders.toList());
  }

  Future<Set<String>> loadSeenIncidentIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kSeenIncidentIds) ?? const <String>[]).toSet();
  }

  Future<void> saveSeenIncidentIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kSeenIncidentIds, ids.toList());
  }
}
