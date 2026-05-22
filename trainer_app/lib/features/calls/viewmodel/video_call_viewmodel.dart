import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/providers/repository_providers.dart';
import 'package:trainer_app/features/calls/service/video_call_service.dart';

enum VideoCallPhase { preJoin, connecting, inCall, notes, done }

class VideoCallState {
  const VideoCallState({
    this.phase = VideoCallPhase.preJoin,
    this.isMicOn = true,
    this.isCameraOn = true,
    this.durationSec = 0,
    this.trainerNote = '',
    this.error,
  });

  final VideoCallPhase phase;
  final bool isMicOn;
  final bool isCameraOn;
  final int durationSec;
  final String trainerNote;
  final String? error;

  VideoCallState copyWith({
    VideoCallPhase? phase,
    bool? isMicOn,
    bool? isCameraOn,
    int? durationSec,
    String? trainerNote,
    Object? error = _sentinel,
  }) =>
      VideoCallState(
        phase: phase ?? this.phase,
        isMicOn: isMicOn ?? this.isMicOn,
        isCameraOn: isCameraOn ?? this.isCameraOn,
        durationSec: durationSec ?? this.durationSec,
        trainerNote: trainerNote ?? this.trainerNote,
        error: error == _sentinel ? this.error : error as String?,
      );
}

const _sentinel = Object();

class VideoCallViewModel extends FamilyNotifier<VideoCallState, String> {
  Timer? _callTimer;
  StreamSubscription<VideoCallServiceEvent>? _subscription;

  @override
  VideoCallState build(String requestId) {
    ref.onDispose(() {
      _callTimer?.cancel();
      _subscription?.cancel();
    });
    final service = ref.read(videoCallServiceProvider);
    _subscription = service.events.listen(_handleEvent);
    return const VideoCallState();
  }

  void _handleEvent(VideoCallServiceEvent event) {
    switch (event.type) {
      case VideoCallServiceEventType.joined:
        _startTimer();
        state = state.copyWith(phase: VideoCallPhase.inCall, error: null);
      case VideoCallServiceEventType.left:
        _stopTimer();
        state = state.copyWith(phase: VideoCallPhase.notes);
      case VideoCallServiceEventType.error:
        state = state.copyWith(
          phase: VideoCallPhase.preJoin,
          error: event.message ?? 'Call error occurred',
        );
    }
  }

  Future<void> join() async {
    state = state.copyWith(phase: VideoCallPhase.connecting, error: null);
    final service = ref.read(videoCallServiceProvider);
    await service.join(
      roomCode: 'dk-aarav-room',
      userId: 'trainer-aarav-001',
      username: 'Aarav',
    );
  }

  Future<void> leave() async {
    final service = ref.read(videoCallServiceProvider);
    await service.leave();
  }

  Future<void> toggleMic() async {
    final service = ref.read(videoCallServiceProvider);
    await service.toggleMic();
    state = state.copyWith(isMicOn: !state.isMicOn);
  }

  Future<void> toggleCamera() async {
    final service = ref.read(videoCallServiceProvider);
    await service.toggleCamera();
    state = state.copyWith(isCameraOn: !state.isCameraOn);
  }

  void updateNote(String note) => state = state.copyWith(trainerNote: note);

  Future<void> saveNotes() async {
    final now = DateTime.now();
    final log = SessionLog(
      id: now.millisecondsSinceEpoch.toString(),
      memberId: 'member-dk-001',
      trainerId: 'trainer-aarav-001',
      startedAt: now.subtract(Duration(seconds: state.durationSec)),
      endedAt: now,
      durationSec: state.durationSec,
      trainerNotes: state.trainerNote.trim().isEmpty
          ? null
          : state.trainerNote.trim(),
    );
    await ref.read(sessionLogRepositoryProvider).save(log);
    state = state.copyWith(phase: VideoCallPhase.done);
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(durationSec: state.durationSec + 1);
    });
  }

  void _stopTimer() => _callTimer?.cancel();
}

final videoCallViewModelProvider =
    NotifierProviderFamily<VideoCallViewModel, VideoCallState, String>(
  VideoCallViewModel.new,
);
