class AppUpdate {
  final String minVersion;
  final String downloadUrl;
  final bool forceUpdate;
  final String releaseNotes;
  final bool githubRelease;
  final String targetVersion;
  final bool updateAvailable;

  AppUpdate({
    required this.minVersion,
    required this.downloadUrl,
    required this.forceUpdate,
    required this.releaseNotes,
    required this.githubRelease,
    required this.targetVersion,
    required this.updateAvailable,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(
      minVersion: json['min_version'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      forceUpdate: json['force_update'] ?? false,
      releaseNotes: json['release_notes'] ?? '',
      githubRelease: json['github_release'] ?? false,
      targetVersion: json['target_version'] ?? '',
      updateAvailable: json['update_available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_version': minVersion,
      'download_url': downloadUrl,
      'force_update': forceUpdate,
      'release_notes': releaseNotes,
      'github_release': githubRelease,
      'target_version': targetVersion,
      'update_available': updateAvailable,
    };
  }
}
