import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/favorite_repository_impl.dart';
import '../../domain/repositories/favorite_repository.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl();
});

final favoriteIdsProvider = AsyncNotifierProvider<FavoriteController, Set<int>>(
  FavoriteController.new,
);

class FavoriteController extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final repository = ref.watch(favoriteRepositoryProvider);

    return repository.getFavoriteIds();
  }

  Future<void> toggleFavorite(int trackId) async {
    final currentIds = state.value ?? await future;

    final updatedIds = Set<int>.from(currentIds);

    if (updatedIds.contains(trackId)) {
      updatedIds.remove(trackId);
    } else {
      updatedIds.add(trackId);
    }

    state = AsyncData(updatedIds);

    try {
      await ref.read(favoriteRepositoryProvider).saveFavoriteIds(updatedIds);
    } catch (_) {
      state = AsyncData(currentIds);
    }
  }

  Future<void> addFavorite(int trackId) async {
    final currentIds = state.value ?? await future;

    if (currentIds.contains(trackId)) return;

    final updatedIds = {...currentIds, trackId};

    state = AsyncData(updatedIds);

    try {
      await ref.read(favoriteRepositoryProvider).saveFavoriteIds(updatedIds);
    } catch (_) {
      state = AsyncData(currentIds);
    }
  }

  Future<void> removeFavorite(int trackId) async {
    final currentIds = state.value ?? await future;

    if (!currentIds.contains(trackId)) return;

    final updatedIds = Set<int>.from(currentIds)..remove(trackId);

    state = AsyncData(updatedIds);

    try {
      await ref.read(favoriteRepositoryProvider).saveFavoriteIds(updatedIds);
    } catch (_) {
      state = AsyncData(currentIds);
    }
  }
}
