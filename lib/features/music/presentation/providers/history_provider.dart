
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl();
});

final trackHistoryProvider =
    AsyncNotifierProvider<HistoryController, List<Track>>(
  HistoryController.new,
);

class HistoryController extends AsyncNotifier<List<Track>> {
  static const int _maxHistoryItems = 100;

  @override
  Future<List<Track>> build() {
    return ref.read(historyRepositoryProvider).getHistory();
  }

  Future<List<Track>> _currentHistory() async {
    return state.asData?.value ?? await future;
  }

  Future<void> addTrack(Track track) async {
    final current = await _currentHistory();

    // Move an already existing track to the beginning.
    final updated = [
      track,
      ...current.where((item) => item.id != track.id),
    ].take(_maxHistoryItems).toList();

    // Do not save if the history has not changed.
    if (current.isNotEmpty &&
        current.first.id == track.id &&
        current.length == updated.length) {
      return;
    }

    await _saveChanges(current, updated);
  }

  Future<void> clearHistory() async {
    final current = await _currentHistory();

    state = const AsyncData([]);

    try {
      await ref.read(historyRepositoryProvider).clearHistory();
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> _saveChanges(
    List<Track> oldHistory,
    List<Track> newHistory,
  ) async {
    state = AsyncData(List.unmodifiable(newHistory));

    try {
      await ref.read(historyRepositoryProvider).saveHistory(newHistory);
    } catch (_) {
      state = AsyncData(oldHistory);
      rethrow;
    }
  }
}
