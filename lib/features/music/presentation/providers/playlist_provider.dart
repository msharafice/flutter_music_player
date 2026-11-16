import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/playlist_repository_impl.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl();
});

final playlistsProvider =
    AsyncNotifierProvider<PlaylistController, List<Playlist>>(
      PlaylistController.new,
    );

class PlaylistController extends AsyncNotifier<List<Playlist>> {
  @override
  Future<List<Playlist>> build() async {
    final repository = ref.watch(playlistRepositoryProvider);
    return repository.getPlaylists();
  }

  Future<List<Playlist>> _currentPlaylists() async {
    return state.asData?.value ?? await future;
  }

  Future<void> _saveChanges(
    List<Playlist> previous,
    List<Playlist> updated,
  ) async {
    state = AsyncData(List.unmodifiable(updated));

    try {
      await ref.read(playlistRepositoryProvider).savePlaylists(updated);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> createPlaylist(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return;

    final current = await _currentPlaylists();

    final playlist = Playlist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: trimmedName,
      trackIds: const [],
      createdAt: DateTime.now(),
    );

    await _saveChanges(current, [...current, playlist]);
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) return;

    final current = await _currentPlaylists();

    final updated = current.map((playlist) {
      if (playlist.id == playlistId) {
        return playlist.copyWith(name: trimmedName);
      }
      return playlist;
    }).toList();

    await _saveChanges(current, updated);
  }

  Future<void> deletePlaylist(String playlistId) async {
    final current = await _currentPlaylists();

    final updated = current
        .where((playlist) => playlist.id != playlistId)
        .toList();

    await _saveChanges(current, updated);
  }

  Future<void> addTracks(String playlistId, List<int> trackIds) async {
    if (trackIds.isEmpty) return;

    final current = await _currentPlaylists();

    final updated = current.map((playlist) {
      if (playlist.id != playlistId) return playlist;

      final ids = <int>{...playlist.trackIds, ...trackIds};

      return playlist.copyWith(trackIds: ids.toList());
    }).toList();

    await _saveChanges(current, updated);
  }

  Future<void> removeTrack(String playlistId, int trackId) async {
    final current = await _currentPlaylists();

    final updated = current.map((playlist) {
      if (playlist.id != playlistId) return playlist;

      final ids = List<int>.from(playlist.trackIds)..remove(trackId);

      return playlist.copyWith(trackIds: ids);
    }).toList();

    await _saveChanges(current, updated);
  }
}
