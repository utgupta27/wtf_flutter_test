import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guru_app/core/widgets/guru_subpage_scaffold.dart';
import 'package:guru_app/features/calls/viewmodel/video_call_viewmodel.dart';

class VideoCallScreen extends ConsumerWidget {
  const VideoCallScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoCallViewModelProvider(requestId));
    final vm = ref.read(videoCallViewModelProvider(requestId).notifier);

    return switch (state.phase) {
      VideoCallPhase.preJoin => _PreJoinView(
          state: state,
          onJoin: vm.join,
          onToggleMic: vm.toggleMic,
          onToggleCamera: vm.toggleCamera,
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
      VideoCallPhase.rating => _RatingView(
          state: state,
          onRate: vm.selectRating,
          onNoteChanged: vm.updateMemberNote,
          onSubmit: vm.submitRating,
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
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onCancel,
  });
  final VideoCallState state;
  final VoidCallback onJoin;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return GuruSubpageScaffold(
      title: const Text('Ready to Join?'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 48,
              child: Text('A', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aarav',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Personal Trainer',
              style: TextStyle(color: Colors.grey),
            ),
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
            const SizedBox(height: 24),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.videocam_rounded, size: 48, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onToggleMic,
                  icon: Icon(
                    state.isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                  ),
                ),
                IconButton(
                  onPressed: onToggleCamera,
                  icon: Icon(
                    state.isCameraOn
                        ? Icons.videocam_rounded
                        : Icons.videocam_off_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
              Text('Connecting to Aarav…'),
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
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Remote video placeholder (full screen)
            Container(
              color: const Color(0xFF1A1A2E),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white12,
                      child: Text('A', style: TextStyle(fontSize: 44, color: Colors.white)),
                    ),
                    SizedBox(height: 16),
                    Text('Aarav', style: TextStyle(color: Colors.white70, fontSize: 20)),
                  ],
                ),
              ),
            ),
            // Timer
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(state.durationSec),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            // Local self-view placeholder (bottom-right corner)
            Positioned(
              bottom: 100,
              right: 16,
              child: Container(
                width: 80,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white54, size: 36),
                ),
              ),
            ),
            // Controls
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CallButton(
                    icon: state.isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
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
                    label: state.isCameraOn ? 'Camera' : 'Cam Off',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
  Widget build(BuildContext context) {
    return Column(
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

// ── Rating ───────────────────────────────────────────────────────────

class _RatingView extends StatelessWidget {
  const _RatingView({
    required this.state,
    required this.onRate,
    required this.onNoteChanged,
    required this.onSubmit,
  });
  final VideoCallState state;
  final void Function(int) onRate;
  final void Function(String) onNoteChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'How was your session?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'With Aarav · ${_formatDuration(state.durationSec)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                final selected = state.rating != null && star <= state.rating!;
                return IconButton(
                  icon: Icon(
                    selected ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 40,
                    color: selected ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => onRate(star),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: onNoteChanged,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Optional note',
                border: OutlineInputBorder(),
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSubmit,
                child: const Text('Submit Rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }
}

// ── Done ─────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  const _DoneView({required this.onHome});
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Session Logged!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Great work. Your session with Aarav has been saved.',
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
}
