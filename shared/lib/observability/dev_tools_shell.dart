import 'package:flutter/material.dart';

import 'package:shared/observability/dev_build_info.dart';
import 'package:shared/observability/dev_env_snapshot.dart';
import 'package:shared/observability/dev_panel.dart';

/// Wraps the app with a floating dev FAB that opens [showDevPanel].
class DevToolsShell extends StatelessWidget {
  const DevToolsShell({
    super.key,
    required this.child,
    required this.buildInfo,
    required this.env,
  });

  final Widget child;
  final DevBuildInfo buildInfo;
  final DevEnvSnapshot env;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: 12,
          bottom: 12,
          child: Material(
            elevation: 4,
            shape: const CircleBorder(),
            color: Colors.black.withValues(alpha: 0.65),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => showDevPanel(
                context,
                buildInfo: buildInfo,
                env: env,
              ),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
