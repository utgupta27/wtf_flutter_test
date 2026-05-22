enum VideoCallServiceEventType {
  joined,
  left,
  error,
  reconnecting,
  reconnected,
}

class VideoCallServiceEvent {
  const VideoCallServiceEvent(this.type, {this.message});
  final VideoCallServiceEventType type;
  final String? message;
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
