import 'package:package_info_plus/package_info_plus.dart';

/// App build metadata shown in the DevPanel.
class DevBuildInfo {
  const DevBuildInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  final String appName;
  final String version;
  final String buildNumber;
  final String packageName;

  String get versionLabel => '$version+$buildNumber';

  static DevBuildInfo? _cached;

  /// Loads package info once and caches for the session.
  static Future<DevBuildInfo> load() async {
    if (_cached != null) {
      return _cached!;
    }
    final info = await PackageInfo.fromPlatform();
    _cached = DevBuildInfo(
      appName: info.appName,
      version: info.version,
      buildNumber: info.buildNumber,
      packageName: info.packageName,
    );
    return _cached!;
  }

  /// Clears cache (tests).
  static void resetForTest() {
    _cached = null;
  }
}
