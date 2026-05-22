import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:trainer_app/core/constants.dart';
import 'package:trainer_app/features/calls/service/video_call_service.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class HmsVideoCallService implements VideoCallService, HMSUpdateListener {
  HmsVideoCallService() : _hmsSDK = HMSSDK();

  final HMSSDK _hmsSDK;
  final StreamController<VideoCallServiceEvent> _controller =
      StreamController<VideoCallServiceEvent>.broadcast();

  bool _micEnabled = true;
  bool _cameraEnabled = true;
  bool _initialized = false;

  @override
  Stream<VideoCallServiceEvent> get events => _controller.stream;

  @override
  bool get isMicEnabled => _micEnabled;

  @override
  bool get isCameraEnabled => _cameraEnabled;

  @override
  Future<void> join({
    required String roomCode,
    required String userId,
    required String username,
    required String role,
  }) async {
    if (!_initialized) {
      await _hmsSDK.build();
      _hmsSDK.addUpdateListener(listener: this);
      _initialized = true;
    }
    final token = await _fetchToken(
      roomId: roomCode,
      userId: userId,
      role: role,
    );
    if (token == null) {
      _controller.add(const VideoCallServiceEvent(
        VideoCallServiceEventType.error,
        message: 'Could not fetch call token. Is the token server running?',
      ));
      return;
    }
    await _hmsSDK.join(
      config: HMSConfig(userName: username, authToken: token),
    );
  }

  @override
  Future<void> leave() async {
    await _hmsSDK.leave();
    _controller.add(const VideoCallServiceEvent(VideoCallServiceEventType.left));
  }

  @override
  Future<void> toggleMic() async {
    _micEnabled = !_micEnabled;
    await _hmsSDK.toggleMicMuteState();
  }

  @override
  Future<void> toggleCamera() async {
    _cameraEnabled = !_cameraEnabled;
    await _hmsSDK.toggleCameraMuteState();
  }

  @override
  Future<void> flipCamera() async {
    await _hmsSDK.switchCamera();
  }

  @override
  void dispose() {
    _hmsSDK.removeUpdateListener(listener: this);
    _hmsSDK.destroy();
    _controller.close();
  }

  Future<String?> _fetchToken({
    required String roomId,
    required String userId,
    required String role,
  }) async {
    try {
      final client = HttpClient();
      final req = await client.postUrl(
        Uri.parse('${AppConstants.tokenServerBaseUrl}/token'),
      );
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'roomId': roomId,
        'userId': userId,
        'role': role,
      }));
      final res = await req.close();
      if (res.statusCode != 200) return null;
      final body = await utf8.decoder.bind(res).join();
      return (jsonDecode(body) as Map<String, dynamic>)['token'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  void onJoin({required HMSRoom room}) => _controller.add(
        const VideoCallServiceEvent(VideoCallServiceEventType.joined),
      );

  @override
  void onHMSError({required HMSException error}) => _controller.add(
        VideoCallServiceEvent(
          VideoCallServiceEventType.error,
          message: error.message,
        ),
      );

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {}

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onReconnecting() => _controller.add(
        const VideoCallServiceEvent(VideoCallServiceEventType.reconnecting),
      );

  @override
  void onReconnected() => _controller.add(
        const VideoCallServiceEvent(VideoCallServiceEventType.reconnected),
      );

  @override
  void onChangeTrackStateRequest({
    required HMSTrackChangeRequest hmsTrackChangeRequest,
  }) {}

  @override
  void onRemovedFromRoom({
    required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
  }) {}

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {}
}
