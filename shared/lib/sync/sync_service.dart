import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared/constants/sync_constants.dart';
import 'package:shared/models/call_request.dart';
import 'package:shared/models/call_request_json.dart';
import 'package:shared/models/message.dart';
import 'package:shared/models/message_json.dart';
import 'package:shared/models/room_meta_json.dart';
import 'package:shared/models/session_log.dart';
import 'package:shared/models/session_log_json.dart';
import 'package:shared/models/typing_presence.dart';
import 'package:shared/models/typing_presence_json.dart';
import 'package:shared/sync/message_status_merge.dart';

/// Local-first sync: Hive is source for UI; Node hub replicates across apps.
class SyncService {
  SyncService({
    required this.baseUrl,
    required Box<dynamic> messagesBox,
    required Box callRequestsBox,
    required Box sessionLogsBox,
    required Box roomMetaBox,
    required Box<dynamic> outboxBox,
    required Box<dynamic> settingsBox,
    required Box<dynamic> typingBox,
    this.networkEnabled = true,
  })  : _messagesBox = messagesBox,
        _callRequestsBox = callRequestsBox,
        _sessionLogsBox = sessionLogsBox,
        _roomMetaBox = roomMetaBox,
        _outboxBox = outboxBox,
        _settingsBox = settingsBox,
        _typingBox = typingBox;

  final String baseUrl;
  final Box<dynamic> _messagesBox;
  final Box _callRequestsBox;
  final Box _sessionLogsBox;
  final Box _roomMetaBox;
  final Box<dynamic> _outboxBox;
  final Box<dynamic> _settingsBox;
  final Box<dynamic> _typingBox;
  final bool networkEnabled;

  final _tickController = StreamController<void>.broadcast();
  Stream<void> get ticks => _tickController.stream;

  Timer? _pollTimer;
  bool _busy = false;
  bool _syncAgain = false;

  static const _keyLastSync = 'sync_last_at';
  static const _keyMessagesLastSync = 'messages_last_sync_at';

  void startPolling({Duration interval = const Duration(milliseconds: 1500)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => syncOnce());
    unawaited(syncOnce());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void dispose() {
    stopPolling();
    _tickController.close();
  }

  Future<void> syncOnce() async {
    if (!networkEnabled) return;
    if (_busy) {
      _syncAgain = true;
      return;
    }
    _busy = true;
    try {
      await _flushOutbox();
      await _pullRemote();
      _tickController.add(null);
    } catch (e, st) {
      debugPrint('SyncService error: $e\n$st');
    } finally {
      _busy = false;
      if (_syncAgain) {
        _syncAgain = false;
        unawaited(syncOnce());
      }
    }
  }

  /// Reliable message-only sync: flush outbox then pull full chat thread.
  Future<void> syncMessagesNow() async {
    if (!networkEnabled) return;
    if (_busy) {
      _syncAgain = true;
      return;
    }
    _busy = true;
    var changed = false;
    try {
      changed = await _flushMessageOutbox();
      // Full-thread pull so peer messages are never missed by cursor drift.
      changed = await _pullMessagesForChat(
            SyncConstants.defaultChatId,
            since: DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
          ) ||
          changed;
      if (changed) {
        _tickController.add(null);
      }
    } catch (e, st) {
      debugPrint('SyncService message sync error: $e\n$st');
    } finally {
      _busy = false;
      if (_syncAgain) {
        _syncAgain = false;
        unawaited(syncMessagesNow());
      }
    }
  }

  void enqueueMessage(Message message) {
    _outboxBox.put(
      'msg-${message.id}',
      {'type': 'message', 'payload': message.toJson()},
    );
    unawaited(syncMessagesNow());
  }

  void enqueueTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) {
    _outboxBox.put(
      'typing-$chatId-$userId',
      {
        'type': 'typing',
        'payload': {
          'chatId': chatId,
          'userId': userId,
          'isTyping': isTyping,
        },
      },
    );
    unawaited(syncOnce());
  }

  void enqueueMessageStatus(String messageId, MessageStatus status) {
    _outboxBox.put(
      'status-$messageId',
      {
        'type': 'messageStatus',
        'payload': {'id': messageId, 'status': status.name},
      },
    );
    unawaited(syncOnce());
  }

  void enqueueCallRequest(CallRequest request) {
    _outboxBox.put(
      'cr-${request.id}',
      {'type': 'callRequest', 'payload': request.toJson()},
    );
    unawaited(syncOnce());
  }

  void enqueueCallRequestPatch(String id, CallRequestStatus status,
      {String? declineReason}) {
    _outboxBox.put(
      'crpatch-$id-${DateTime.now().millisecondsSinceEpoch}',
      {
        'type': 'callRequestPatch',
        'payload': {
          'id': id,
          'status': status.name,
          if (declineReason != null) 'declineReason': declineReason,
        },
      },
    );
    unawaited(syncOnce());
  }

  void enqueueSessionLog(SessionLog log) {
    _outboxBox.put(
      'sl-${log.id}',
      {'type': 'sessionLog', 'payload': log.toJson()},
    );
    unawaited(syncOnce());
  }

  Future<void> _flushOutbox() async {
    await _flushMessageOutbox();
    final keys = _outboxBox.keys.toList();
    for (final key in keys) {
      final raw = _outboxBox.get(key);
      if (raw is! Map) continue;
      final type = raw['type'] as String?;
      if (type == 'message' || type == 'messageStatus') {
        continue;
      }
      final payload = Map<String, dynamic>.from(raw['payload'] as Map);
      final ok = await _pushItem(type, payload);
      if (ok) {
        await _outboxBox.delete(key);
      }
    }
  }

  Future<bool> _flushMessageOutbox() async {
    var changed = false;
    final keys = _outboxBox.keys.toList();
    for (final key in keys) {
      final raw = _outboxBox.get(key);
      if (raw is! Map) continue;
      final type = raw['type'] as String?;
      if (type != 'message' && type != 'messageStatus') {
        continue;
      }
      final payload = Map<String, dynamic>.from(raw['payload'] as Map);
      final ok = await _pushItem(type, payload);
      if (ok) {
        await _outboxBox.delete(key);
        changed = true;
      } else if (kDebugMode) {
        debugPrint('SyncService: failed to push $type for outbox key $key');
      }
    }
    return changed;
  }

  Future<bool> _pushItem(String? type, Map<String, dynamic> payload) async {
    final uri = Uri.parse(baseUrl);
    try {
      switch (type) {
        case 'message':
          final res = await http.post(
            uri.replace(path: '/sync/messages'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );
          if (res.statusCode == 201 || res.statusCode == 200) {
            final body = jsonDecode(res.body) as Map<String, dynamic>;
            final msg = MessageJson.fromJson(body);
            final existingRaw = _messagesBox.get(msg.id);
            if (existingRaw != null) {
              final existing = Message.fromMap(
                Map<String, dynamic>.from(existingRaw as Map),
              );
              await _messagesBox.put(
                msg.id,
                msg
                    .copyWith(
                      status: mergeMessageStatus(existing.status, msg.status),
                    )
                    .toMap(),
              );
            } else {
              await _messagesBox.put(msg.id, msg.toMap());
            }
            return true;
          }
          return false;
        case 'typing':
          final res = await http.post(
            uri.replace(path: '/sync/typing'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );
          return res.statusCode == 200;
        case 'messageStatus':
          final id = payload['id'] as String;
          final res = await http.patch(
            uri.replace(path: '/sync/messages/$id/status'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': payload['status']}),
          );
          return res.statusCode == 200;
        case 'callRequest':
          final res = await http.post(
            uri.replace(path: '/sync/call-requests'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );
          return res.statusCode == 201 || res.statusCode == 200;
        case 'callRequestPatch':
          final id = payload['id'] as String;
          final res = await http.patch(
            uri.replace(path: '/sync/call-requests/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );
          if (res.statusCode == 200 &&
              payload['status'] == CallRequestStatus.approved.name) {
            await http.post(
              uri.replace(path: '/rooms'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'callRequestId': id}),
            );
          }
          return res.statusCode == 200;
        case 'sessionLog':
          final res = await http.post(
            uri.replace(path: '/sync/session-logs'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          );
          return res.statusCode == 201 || res.statusCode == 200;
        default:
          return true;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> _pullRemote() async {
    final since = _settingsBox.get(_keyLastSync) as String?;
    final sinceParam = since ?? DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

    await _pullMessagesForChat(SyncConstants.defaultChatId, since: sinceParam);
    await _pullTyping(SyncConstants.defaultChatId);
    await _pullCallRequests();
    await _pullSessionLogs();

    await _settingsBox.put(_keyLastSync, DateTime.now().toIso8601String());
  }

  /// Pull messages for [chatId]. Returns true if Hive message store changed.
  Future<bool> _pullMessagesForChat(String chatId, {String? since}) async {
    final sinceParam = since ??
        _settingsBox.get(_keyMessagesLastSync) as String? ??
        DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

    final uri = Uri.parse(baseUrl).replace(
      path: '/sync/messages',
      queryParameters: {
        'chatId': chatId,
        'since': sinceParam,
      },
    );
    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        if (kDebugMode) {
          debugPrint(
            'SyncService: GET /sync/messages failed ${res.statusCode} ${res.body}',
          );
        }
        return false;
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body['messages'] as List<dynamic>? ?? [];
      var changed = false;
      for (final item in list) {
        final msg = MessageJson.fromJson(Map<String, dynamic>.from(item as Map));
        final existingRaw = _messagesBox.get(msg.id);
        if (existingRaw != null) {
          final existing = Message.fromMap(
            Map<String, dynamic>.from(existingRaw as Map),
          );
          final merged = msg.copyWith(
            status: mergeMessageStatus(existing.status, msg.status),
          );
          if (merged != existing) {
            await _messagesBox.put(msg.id, merged.toMap());
            changed = true;
          }
        } else {
          await _messagesBox.put(msg.id, msg.toMap());
          changed = true;
        }
      }
      if (changed || list.isNotEmpty) {
        await _settingsBox.put(_keyMessagesLastSync, DateTime.now().toIso8601String());
      }
      return changed;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SyncService: pull messages error $e');
      }
      return false;
    }
  }

  Future<void> _pullTyping(String chatId) async {
    final uri = Uri.parse(baseUrl).replace(
      path: '/sync/typing',
      queryParameters: {'chatId': chatId},
    );
    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) return;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body['typing'] as List<dynamic>? ?? [];
      await _typingBox.put('__meta__', {'chatId': chatId, 'at': DateTime.now().toIso8601String()});
      final keysToRemove = _typingBox.keys
          .where((k) => k != '__meta__')
          .toList();
      for (final key in keysToRemove) {
        await _typingBox.delete(key);
      }
      for (final item in list) {
        final presence = TypingPresenceJson.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
        await _typingBox.put(
          presence.userId,
          presence.toJson(),
        );
      }
    } catch (_) {}
  }

  /// Latest typing presence for [userId] in the active chat poll snapshot.
  TypingPresence? getPeerTyping(String userId) {
    final raw = _typingBox.get(userId);
    if (raw is! Map) return null;
    return TypingPresenceJson.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> _pullCallRequests() async {
    final guruUri = Uri.parse(baseUrl).replace(
      path: '/sync/call-requests',
      queryParameters: {'memberId': SyncConstants.memberId},
    );
    final trainerUri = Uri.parse(baseUrl).replace(
      path: '/sync/call-requests',
      queryParameters: {'trainerId': SyncConstants.trainerId},
    );

    for (final uri in [guruUri, trainerUri]) {
      final res = await http.get(uri);
      if (res.statusCode != 200) continue;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body['callRequests'] as List<dynamic>? ?? [];
      for (final item in list) {
        final cr = CallRequestJson.fromJson(Map<String, dynamic>.from(item as Map));
        await _callRequestsBox.put(cr.id, cr);
        if (cr.status == CallRequestStatus.approved) {
          await _fetchRoom(cr.id);
        }
      }
    }
  }

  Future<void> _fetchRoom(String callRequestId) async {
    final uri = Uri.parse(baseUrl).replace(
      path: '/rooms/by-request/$callRequestId',
    );
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final meta = RoomMetaJson.fromJson(
          Map<String, dynamic>.from(jsonDecode(res.body) as Map),
        );
        await _roomMetaBox.put(meta.callRequestId, meta);
      }
    } catch (_) {}
  }

  Future<void> _pullSessionLogs() async {
    final uri = Uri.parse(baseUrl).replace(
      path: '/sync/session-logs',
      queryParameters: {
        'memberId': SyncConstants.memberId,
        'trainerId': SyncConstants.trainerId,
      },
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) return;
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['sessionLogs'] as List<dynamic>? ?? [];
    for (final item in list) {
      final log = SessionLogJson.fromJson(Map<String, dynamic>.from(item as Map));
      await _sessionLogsBox.put(log.id, log);
    }
  }

  /// Whether join is allowed (within [SyncConstants.joinWindowMinutes] of start).
  static bool canJoinCall(DateTime scheduledFor) {
    final now = DateTime.now();
    final openAt = scheduledFor.subtract(
      const Duration(minutes: SyncConstants.joinWindowMinutes),
    );
    return !now.isBefore(openAt);
  }
}
