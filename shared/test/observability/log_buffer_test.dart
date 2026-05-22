import 'package:flutter_test/flutter_test.dart';
import 'package:shared/observability/log_buffer.dart';
import 'package:shared/observability/log_entry.dart';
import 'package:shared/observability/log_tag.dart';

void main() {
  setUp(() => LogBuffer.instance.clear());

  test('evicts oldest entry when capacity exceeded', () {
    final buffer = LogBuffer.instance;
    for (var i = 0; i < LogBuffer.capacity + 1; i++) {
      buffer.add(
        LogEntry(
          tag: LogTag.chat,
          message: 'msg-$i',
          at: DateTime.now(),
        ),
      );
    }
    expect(buffer.entries.length, LogBuffer.capacity);
    expect(buffer.entries.first.message, 'msg-20');
    expect(buffer.entries.last.message, 'msg-1');
  });

  test('entries expose tag prefix', () {
    LogBuffer.instance.add(
      LogEntry(
        tag: LogTag.rtc,
        message: 'join',
        at: DateTime.now(),
      ),
    );
    expect(LogBuffer.instance.entries.first.prefix, '[RTC]');
  });
}
