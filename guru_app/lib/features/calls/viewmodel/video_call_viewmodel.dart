import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/constants.dart';
import 'package:guru_app/providers/repository_providers.dart';
import 'package:guru_app/providers/sync_provider.dart';
import 'package:guru_app/features/calls/service/video_call_service.dart';

enum VideoCallPhase { preJoin, connecting, inCall, rating, done }

class VideoCallState {
  const VideoCallState({
    this.phase = VideoCallPhase.preJoin,
    this.isMicOn = true,
    this.isCameraOn = true,
    this.isReconnecting = false,
    this.durationSec = 0,
    this.rating,
    this.memberNote = '',
    this.error,
  });

  final VideoCallPhase phase;
  final bool isMicOn;
  final bool isCameraOn;
  final bool isReconnecting;
  final int durationSec;
  final int? rating;
  final String memberNote;
  final String? error;

  VideoCallState copyWith({
    VideoCallPhase? phase,
    bool? isMicOn,
    bool? isCameraOn,
    bool? isReconnecting,
    int? durationSec,
    Object? rating = _sentinel,
    String? memberNote,
    Object? error = _sentinel,
  }) =>
      VideoCallState(
        phase: phase ?? this.phase,
        isMicOn: isMicOn ?? this.isMicOn,
        isCameraOn: isCameraOn ?? this.isCameraOn,
        isReconnecting: isReconnecting ?? this.isReconnecting,
        durationSec: durationSec ?? this.durationSec,
        rating: rating == _sentinel ? this.rating : rating as int?,
        memberNote: memberNote ?? this.memberNote,
        error: error == _sentinel ? this.error : error as String?,
      );
}

const _sentinel = Object();

class VideoCallViewModel extends FamilyNotifier<VideoCallState, String> {
  Timer? _callTimer;
  StreamSubscription<VideoCallServiceEvent>? _subscription;
  late String _requestId;

  @override
  VideoCallState build(String requestId) {
    _requestId = requestId;
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
        state = state.copyWith(
          phase: VideoCallPhase.inCall,
          error: null,
          isReconnecting: false,
        );
      case VideoCallServiceEventType.left:
        _stopTimer();
        state = state.copyWith(phase: VideoCallPhase.rating);
      case VideoCallServiceEventType.error:
        state = state.copyWith(
          phase: VideoCallPhase.preJoin,
          error: event.message ?? 'Call error occurred',
          isReconnecting: false,
        );
      case VideoCallServiceEventType.reconnecting:
        state = state.copyWith(isReconnecting: true);
      case VideoCallServiceEventType.reconnected:
        state = state.copyWith(isReconnecting: false);
    }
  }

  Future<void> join() async {
    final request =
        await ref.read(callRequestRepositoryProvider).getById(_requestId);
    if (request == null) {
      state = state.copyWith(error: 'Call request not found');
      return;
    }
    if (!SyncService.canJoinCall(request.scheduledFor)) {
      state = state.copyWith(
        error: 'Join opens 10 minutes before the scheduled time',
      );
      return;
    }

    final roomBox = Hive.box(AppConstants.hiveBoxRoomMeta);
    final room = roomBox.get(_requestId) as RoomMeta?;
    if (room == null) {
      state = state.copyWith(
        error: 'Room not ready. Wait for trainer approval.',
      );
      return;
    }

    state = state.copyWith(phase: VideoCallPhase.connecting, error: null);
    final service = ref.read(videoCallServiceProvider);
    await service.join(
      roomCode: room.hmsRoomId,
      userId: SyncConstants.memberId,
      username: 'DK',
    );
  }

  Future<void> leave() async {
    await ref.read(videoCallServiceProvider).leave();
  }

  Future<void> toggleMic() async {
    await ref.read(videoCallServiceProvider).toggleMic();
    state = state.copyWith(isMicOn: !state.isMicOn);
  }

  Future<void> toggleCamera() async {
    await ref.read(videoCallServiceProvider).toggleCamera();
    state = state.copyWith(isCameraOn: !state.isCameraOn);
  }

  Future<void> flipCamera() async {
    await ref.read(videoCallServiceProvider).flipCamera();
  }

  void selectRating(int stars) => state = state.copyWith(rating: stars);

  void updateMemberNote(String note) =>
      state = state.copyWith(memberNote: note);

  Future<void> submitRating() async {
    final stars = state.rating;
    if (stars == null) {
      state = state.copyWith(error: 'Please select a rating');
      return;
    }

    final now = DateTime.now();
    final log = SessionLog(
      id: '$_requestId-${now.millisecondsSinceEpoch}',
      memberId: SyncConstants.memberId,
      trainerId: SyncConstants.trainerId,
      startedAt: now.subtract(Duration(seconds: state.durationSec)),
      endedAt: now,
      durationSec: state.durationSec,
      rating: stars,
      memberNotes: state.memberNote.isEmpty ? null : state.memberNote,
    );

    await ref.read(sessionLogRepositoryProvider).save(log);
    ref.read(syncServiceProvider).enqueueSessionLog(log);
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
