import 'package:shared/observability/env_mask.dart';

/// Immutable environment snapshot for the DevPanel (values pre-masked).
class DevEnvSnapshot {
  const DevEnvSnapshot(this.entries);

  final Map<String, String> entries;

  factory DevEnvSnapshot.fromRaw(Map<String, String> raw) {
    return DevEnvSnapshot(maskEnvMap(raw));
  }
}
