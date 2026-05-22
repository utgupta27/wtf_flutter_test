import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/chat/data/chat_repository.dart';
import 'package:shared/sync/sync_service.dart';

/// Override in each app's ProviderScope / provider setup.
final sharedChatRepositoryProvider = Provider<ChatRepository>((ref) {
  throw UnimplementedError(
    'Override sharedChatRepositoryProvider with HiveChatRepository',
  );
});

final sharedSyncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError(
    'Override sharedSyncServiceProvider with app SyncService',
  );
});

final sharedSyncTickProvider = StreamProvider<void>((ref) {
  return ref.watch(sharedSyncServiceProvider).ticks;
});
