import 'package:hmssdk_flutter/hmssdk_flutter.dart';

enum VideoCallServiceEventType {
  joined,
  left,
  error,
  reconnecting,
  reconnected,
  tracksUpdated,
  deviceStateUpdated,
}

class VideoCallServiceEvent {
  const VideoCallServiceEvent(
    this.type, {
    this.message,
    this.localVideo,
    this.remoteVideo,
    this.isMicOn,
    this.isCameraOn,
    this.remotePeerJoined,
  });
  final VideoCallServiceEventType type;
  final String? message;
  final HMSVideoTrack? localVideo;
  final HMSVideoTrack? remoteVideo;
  final bool? isMicOn;
  final bool? isCameraOn;
  final bool? remotePeerJoined;
}

abstract interface class VideoCallService {
  Stream<VideoCallServiceEvent> get events;
  bool get isMicEnabled;
  bool get isCameraEnabled;
  Future<void> join({
    required String roomCode,
    required String userId,
    required String username,
    required String role,
  });
  Future<void> leave();
  Future<void> toggleMic();
  Future<void> toggleCamera();
  Future<void> flipCamera();
  void dispose();
}
