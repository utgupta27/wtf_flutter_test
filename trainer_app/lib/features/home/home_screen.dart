import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trainer_app/features/auth/viewmodel/auth_viewmodel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final name = authState.value?.name ?? 'Trainer';

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $name 👋'),
        actions: [
          Chip(
            label: const Text('Trainer'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Center(child: Text('Home — coming soon')),
    );
  }
}
