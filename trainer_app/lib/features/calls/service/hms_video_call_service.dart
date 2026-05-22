import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:trainer_app/core/constants.dart';
import 'package:trainer_app/features/calls/service/video_call_service.dart';

class HmsVideoCallService implements VideoCallService, HMSUpdateListener {
  HmsVideoCallService() : _hmsSDK = HMSSDK();

  final HMSSDK _hmsSDK;
  final StreamController<VideoCallServiceEvent> _controller =
      StreamController<VideoCallServiceEvent>.broadcast();

  bool _micEnabled = true;
  bool _cameraEnabled = true;
  bool _initialized = false;
  bool _inRoom = false;
  bool _remotePeerJoined = false;
  HMSVideoTrack? _localVideo;
  HMSVideoTrack? _remoteVideo;

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
    _inRoom = false;
    _remotePeerJoined = false;
    _localVideo = null;
    _remoteVideo = null;
    _controller.add(const VideoCallServiceEvent(VideoCallServiceEventType.left));
  }

  @override
  Future<void> toggleMic() async {
    if (!_inRoom) {
      _micEnabled = !_micEnabled;
      _emitDeviceState();
      return;
    }
    await _hmsSDK.toggleMicMuteState();
    await _syncDeviceStateFromSdk();
  }

  @override
  Future<void> toggleCamera() async {
    if (!_inRoom) {
      _cameraEnabled = !_cameraEnabled;
      _emitDeviceState();
      return;
    }
    await _hmsSDK.toggleCameraMuteState();
    await _syncDeviceStateFromSdk();
  }

  @override
  Future<void> flipCamera() async {
    if (!_inRoom) return;
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
      final req = await client
          .postUrl(Uri.parse('${AppConstants.tokenServerBaseUrl}/token'));
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

  void _emitDeviceState() {
    _controller.add(VideoCallServiceEvent(
      VideoCallServiceEventType.deviceStateUpdated,
      isMicOn: _micEnabled,
      isCameraOn: _cameraEnabled,
    ));
  }

  void _emitTracks() {
    _controller.add(VideoCallServiceEvent(
      VideoCallServiceEventType.tracksUpdated,
      localVideo: _localVideo,
      remoteVideo: _remoteVideo,
      remotePeerJoined: _remotePeerJoined,
    ));
  }

  Future<void> _syncDeviceStateFromSdk() async {
    final HMSLocalPeer? local = await _hmsSDK.getLocalPeer();
    if (local == null) return;
    final bool audioMuted = await _hmsSDK.isAudioMute(peer: local);
    final bool videoMuted = await _hmsSDK.isVideoMute(peer: local);
    _micEnabled = !audioMuted;
    _cameraEnabled = !videoMuted;
    _emitDeviceState();
  }

  Future<void> _applyInitialDeviceState() async {
    final HMSLocalPeer? local = await _hmsSDK.getLocalPeer();
    if (local == null) return;
    final bool audioMuted = await _hmsSDK.isAudioMute(peer: local);
    if (_micEnabled == audioMuted) {
      await _hmsSDK.toggleMicMuteState();
    }
    final bool videoMuted = await _hmsSDK.isVideoMute(peer: local);
    if (_cameraEnabled == videoMuted) {
      await _hmsSDK.toggleCameraMuteState();
    }
    await _syncDeviceStateFromSdk();
  }

  Future<void> _syncTracksFromPeers() async {
    final HMSLocalPeer? local = await _hmsSDK.getLocalPeer();
    _localVideo = _cameraEnabled ? local?.videoTrack : null;
    _remoteVideo = null;
    _remotePeerJoined = false;
    final List<HMSPeer>? peers = await _hmsSDK.getPeers();
    if (peers != null) {
      for (final HMSPeer peer in peers) {
        if (!peer.isLocal) {
          _remotePeerJoined = true;
          if (peer.videoTrack != null && !peer.videoTrack!.isMute) {
            _remoteVideo = peer.videoTrack;
          }
          break;
        }
      }
    }
    _emitTracks();
  }

  void _applyVideoTrack({
    required HMSPeer peer,
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
  }) {
    if (peer.isLocal) {
      if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
        if (trackUpdate == HMSTrackUpdate.trackRemoved) {
          _micEnabled = true;
        } else {
          _micEnabled = !track.isMute;
        }
        _emitDeviceState();
        return;
      }
      if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
        if (trackUpdate == HMSTrackUpdate.trackRemoved) {
          _localVideo = null;
        } else {
          _cameraEnabled = !track.isMute;
          _localVideo = _cameraEnabled ? track as HMSVideoTrack : null;
        }
        _emitDeviceState();
        _emitTracks();
        return;
      }
    }

    if (track.kind != HMSTrackKind.kHMSTrackKindVideo) return;
    final HMSVideoTrack videoTrack = track as HMSVideoTrack;
    if (trackUpdate == HMSTrackUpdate.trackRemoved) {
      _remoteVideo = null;
    } else {
      _remoteVideo = track.isMute ? null : videoTrack;
    }
    _emitTracks();
  }

  @override
  void onJoin({required HMSRoom room}) {
    _inRoom = true;
    unawaited(() async {
      await _syncTracksFromPeers();
      await _applyInitialDeviceState();
    }());
    _controller.add(
      const VideoCallServiceEvent(VideoCallServiceEventType.joined),
    );
  }

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
  }) {
    if (!peer.isLocal) {
      _remotePeerJoined = true;
    }
    _applyVideoTrack(peer: peer, track: track, trackUpdate: trackUpdate);
  }

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
  void onReconnected() {
    unawaited(_syncTracksFromPeers());
    _controller.add(
      const VideoCallServiceEvent(VideoCallServiceEventType.reconnected),
    );
  }

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
  }) {
    if (removedPeers.any((HMSPeer p) => !p.isLocal)) {
      _remotePeerJoined = false;
      _remoteVideo = null;
    }
    unawaited(_syncTracksFromPeers());
  }
}
