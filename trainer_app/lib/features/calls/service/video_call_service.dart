enum VideoCallServiceEventType { joined, left, error }

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
  });
  Future<void> leave();
  Future<void> toggleMic();
  Future<void> toggleCamera();
  void dispose();
}
