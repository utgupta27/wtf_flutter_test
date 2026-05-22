import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:trainer_app/core/root_scaffold.dart';
import 'package:trainer_app/core/theme/app_theme.dart';
import 'package:trainer_app/router/app_router.dart';

class TrainerApp extends ConsumerWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final buildInfo = DevContext.buildInfo!;
    final env = DevContext.env!;
    return MaterialApp.router(
      title: 'WTF Trainer',
      theme: AppTheme.light,
      routerConfig: router,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      builder: (context, child) => DevToolsShell(
        buildInfo: buildInfo,
        env: env,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
