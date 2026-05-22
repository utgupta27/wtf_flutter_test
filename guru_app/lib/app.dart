import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import 'package:guru_app/core/root_scaffold.dart';
import 'package:guru_app/core/theme/app_theme.dart';
import 'package:guru_app/router/app_router.dart';

class GuruApp extends ConsumerWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final buildInfo = DevContext.buildInfo!;
    final env = DevContext.env!;
    return MaterialApp.router(
      title: 'Guru App',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      builder: (context, child) => DevToolsShell(
        buildInfo: buildInfo,
        env: env,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
