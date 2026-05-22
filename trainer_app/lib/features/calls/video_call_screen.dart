import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import 'package:trainer_app/features/calls/viewmodel/video_call_viewmodel.dart';
import 'package:shared/constants/ui_copy.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key, required this.requestId});
  final String requestId;

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(videoCallViewModelProvider(widget.requestId).notifier)
          .preparePermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoCallViewModelProvider(widget.requestId));
    final vm = ref.read(videoCallViewModelProvider(widget.requestId).notifier);

    return switch (state.phase) {
      VideoCallPhase.preJoin => _PreJoinView(
          state: state,
          onJoin: vm.join,
          onCancel: () => context.go('/home'),
        ),
      VideoCallPhase.connecting => const _ConnectingView(),
      VideoCallPhase.inCall => _InCallView(
          state: state,
          onToggleMic: vm.toggleMic,
          onToggleCamera: vm.toggleCamera,
          onFlip: vm.flipCamera,
          onLeave: vm.leave,
        ),
      VideoCallPhase.notes => _NotesView(
          state: state,
          onNoteChanged: vm.updateNote,
          onSave: vm.saveNotes,
        ),
      VideoCallPhase.done => _DoneView(onHome: () => context.go('/home')),
    };
  }
}

// ── Pre-join ─────────────────────────────────────────────────────────

class _PreJoinView extends StatelessWidget {
  const _PreJoinView({
    required this.state,
    required this.onJoin,
    required this.onCancel,
  });
  final VideoCallState state;
  final VoidCallback onJoin;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Join Call')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                UiCopy.joinPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 48,
                child: Text('DK', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 16),
              const Text(
                'DK',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Member', style: TextStyle(color: Colors.grey)),
              if (state.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onJoin,
                  icon: const Icon(Icons.video_call_rounded),
                  label: const Text('Join Call'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Connecting ───────────────────────────────────────────────────────

class _ConnectingView extends StatelessWidget {
  const _ConnectingView();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to DK…'),
            ],
          ),
        ),
      );
}

// ── In-call ──────────────────────────────────────────────────────────

class _InCallView extends StatelessWidget {
  const _InCallView({
    required this.state,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onFlip,
    required this.onLeave,
  });
  final VideoCallState state;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onFlip;
  final VoidCallback onLeave;

  String _formatDuration(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              if (state.isReconnecting)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 12),
                        Text(
                          'Reconnecting…',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned.fill(
                child: _CallVideoSurface(
                  track: state.remoteVideo,
                  placeholder: Container(
                    color: const Color(0xFF1A1A2E),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!state.remotePeerJoined) ...[
                            const SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Waiting for the other person to join…',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            const CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.white12,
                              child: Text(
                                'DK',
                                style: TextStyle(fontSize: 36, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'DK',
                              style: TextStyle(color: Colors.white70, fontSize: 20),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Camera is off',
                              style: TextStyle(color: Colors.white38, fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 110,
                    child: _CallVideoSurface(
                      track: state.isCameraOn ? state.localVideo : null,
                      setMirror: true,
                      placeholder: ColoredBox(
                        color: Colors.white12,
                        child: Center(
                          child: Icon(
                            state.isCameraOn
                                ? Icons.person
                                : Icons.videocam_off_rounded,
                            color: Colors.white54,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDuration(state.durationSec),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CallButton(
                      icon: state.isMicOn
                          ? Icons.mic_rounded
                          : Icons.mic_off_rounded,
                      onTap: onToggleMic,
                      label: state.isMicOn ? 'Mute' : 'Unmute',
                    ),
                    const SizedBox(width: 16),
                    _CallButton(
                      icon: Icons.flip_camera_ios_rounded,
                      onTap: onFlip,
                      label: 'Flip',
                    ),
                    const SizedBox(width: 16),
                    _CallButton(
                      icon: Icons.call_end_rounded,
                      onTap: onLeave,
                      label: 'End',
                      backgroundColor: Colors.red,
                    ),
                    const SizedBox(width: 16),
                    _CallButton(
                      icon: state.isCameraOn
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      onTap: onToggleCamera,
                      label: state.isCameraOn ? 'Camera' : 'Camera Off',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

/// Renders a 100ms video track or a fallback placeholder when unavailable.
class _CallVideoSurface extends StatelessWidget {
  const _CallVideoSurface({
    required this.track,
    this.setMirror = false,
    this.placeholder,
  });

  final HMSVideoTrack? track;
  final bool setMirror;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    if (track == null) {
      return placeholder ?? const ColoredBox(color: Color(0xFF1A1A2E));
    }
    return HMSVideoView(
      key: ValueKey<String>(track!.trackId),
      track: track!,
      setMirror: setMirror,
      scaleType: ScaleType.SCALE_ASPECT_FILL,
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.onTap,
    required this.label,
    this.backgroundColor,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 28,
              backgroundColor: backgroundColor ?? Colors.white24,
              child: Icon(icon, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      );
}

// ── Notes ─────────────────────────────────────────────────────────────

class _NotesView extends StatelessWidget {
  const _NotesView({
    required this.state,
    required this.onNoteChanged,
    required this.onSave,
  });
  final VideoCallState state;
  final void Function(String) onNoteChanged;
  final VoidCallback onSave;

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return m == 0 ? '${s}s' : '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Session Notes')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session with DK · ${_formatDuration(state.durationSec)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text(
                'Add trainer notes (optional)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 5,
                maxLength: 300,
                onChanged: onNoteChanged,
                decoration: const InputDecoration(
                  hintText: 'E.g. DK improved squat form significantly…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onSave,
                  child: const Text('Save & Finish'),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Done ─────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  const _DoneView({required this.onHome});
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 80, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Session Logged!',
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  UiCopy.sessionEnded,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: onHome,
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
}
