
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/track.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  static const String _historyKey = 'music_history_v1';

  @override
  Future<List<Track>> getHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final savedItems = preferences.getStringList(_historyKey) ?? [];

    final tracks = <Track>[];

    for (final item in savedItems) {
      try {
        final json = jsonDecode(item) as Map<String, dynamic>;

        tracks.add(
          Track(
            id: (json['id'] as num).toInt(),
            title: json['title'] as String? ?? '',
            artist: json['artist'] as String? ?? '',
            album: json['album'] as String? ?? '',
            path: json['path'] as String? ?? '',
            duration: (json['duration'] as num?)?.toInt() ?? 0,
            artwork: json['artwork'] as String?,
          ),
        );
      } catch (_) {
        // Ignore invalid history entries.
      }
    }

    return tracks;
  }

  @override
  Future<void> saveHistory(List<Track> tracks) async {
    final preferences = await SharedPreferences.getInstance();

    final savedItems = tracks.map((track) {
      return jsonEncode({
        'id': track.id,
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'path': track.path,
        'duration': track.duration,
        'artwork': track.artwork,
      });
    }).toList();

    await preferences.setStringList(_historyKey, savedItems);
  }

  @override
  Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_historyKey);
  }
}
