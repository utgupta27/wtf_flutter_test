import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared/observability/dev_build_info.dart';
import 'package:shared/observability/dev_env_snapshot.dart';
import 'package:shared/observability/log_buffer.dart';
import 'package:shared/observability/log_entry.dart';

/// Opens the developer panel bottom sheet.
void showDevPanel(
  BuildContext context, {
  required DevBuildInfo buildInfo,
  required DevEnvSnapshot env,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _DevPanelSheet(
      buildInfo: buildInfo,
      env: env,
    ),
  );
}

class _DevPanelSheet extends StatefulWidget {
  const _DevPanelSheet({
    required this.buildInfo,
    required this.env,
  });

  final DevBuildInfo buildInfo;
  final DevEnvSnapshot env;

  @override
  State<_DevPanelSheet> createState() => _DevPanelSheetState();
}

class _DevPanelSheetState extends State<_DevPanelSheet> {
  final LogBuffer _buffer = LogBuffer.instance;
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _buffer.addListener(_onLogsChanged);
  }

  @override
  void dispose() {
    _buffer.removeListener(_onLogsChanged);
    super.dispose();
  }

  void _onLogsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.75;
    final logs = _buffer.entries;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Dev Panel',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _sectionTitle(context, 'Build'),
                  _buildSection(context),
                  const SizedBox(height: 16),
                  _sectionTitle(context, 'Environment'),
                  _envSection(context),
                  const SizedBox(height: 16),
                  _sectionTitle(context, 'Recent logs (${LogBuffer.capacity} max)'),
                  if (logs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No logs yet.'),
                    )
                  else
                    ...logs.map((e) => _logTile(context, e)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    final info = widget.buildInfo;
    return _keyValueTable(context, {
      'App': info.appName,
      'Version': info.versionLabel,
      'Package': info.packageName,
    });
  }

  Widget _envSection(BuildContext context) {
    final sorted = widget.env.entries.keys.toList()..sort();
    final map = {
      for (final key in sorted) key: widget.env.entries[key]!,
    };
    return _keyValueTable(context, map);
  }

  Widget _keyValueTable(BuildContext context, Map<String, String> rows) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: rows.entries
          .map(
            (e) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, right: 8),
                  child: Text(
                    e.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SelectableText(
                    e.value,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _logTile(BuildContext context, LogEntry entry) {
    final time = _timeFormat.format(entry.at);
    Color? color;
    switch (entry.level) {
      case LogLevel.warning:
        color = Colors.orange.shade800;
      case LogLevel.error:
        color = Colors.red.shade700;
      case LogLevel.info:
        color = null;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SelectableText(
            entry.displayLine,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
