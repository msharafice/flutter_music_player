import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../models/playlist_model.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  static const String _playlistsKey = 'music_playlists_v1';

  @override
  Future<List<Playlist>> getPlaylists() async {
    final preferences = await SharedPreferences.getInstance();

    final savedPlaylists = preferences.getStringList(_playlistsKey) ?? [];

    final playlists = <Playlist>[];

    for (final item in savedPlaylists) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        playlists.add(PlaylistModel.fromJson(decoded));
      } catch (_) {
        // Ignore invalid saved playlist entries.
      }
    }

    return playlists;
  }

  @override
  Future<void> savePlaylists(List<Playlist> playlists) async {
    final preferences = await SharedPreferences.getInstance();

    final savedPlaylists = playlists.map((playlist) {
      final model = PlaylistModel.fromEntity(playlist);
      return jsonEncode(model.toJson());
    }).toList();

    await preferences.setStringList(_playlistsKey, savedPlaylists);
  }
}
