import 'package:permission_handler/permission_handler.dart';

/// Override for widget tests (defaults to real platform permission flow).
Future<bool> Function()? callPermissionCheckerOverride;

/// Requests camera and microphone access required for 100ms video calls.
Future<bool> ensureCallPermissions() async {
  if (callPermissionCheckerOverride != null) {
    return callPermissionCheckerOverride!();
  }
  final Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,
  ].request();

  final bool cameraGranted =
      statuses[Permission.camera]?.isGranted ?? false;
  final bool micGranted =
      statuses[Permission.microphone]?.isGranted ?? false;
  return cameraGranted && micGranted;
}

/// Opens system settings when the user permanently denied call permissions.
Future<void> openCallPermissionSettings() => openAppSettings();
