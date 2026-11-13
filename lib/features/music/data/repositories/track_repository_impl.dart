
import 'package:media_browser/simple_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';

class TrackRepositoryImpl implements TrackRepository {
  final SimpleMediaQuery _mediaQuery;

  TrackRepositoryImpl(this._mediaQuery);

  @override
  Future<List<Track>> getTracks() async {
    final permissionStatus = await Permission.audio.request();

    if (!permissionStatus.isGranted) {
      if (permissionStatus.isPermanentlyDenied) {
        throw Exception(
          'Audio permission is permanently denied. '
          'Please enable it in app settings.',
        );
      }

      throw Exception('Audio permission was denied: $permissionStatus');
    }

    final audios = await _mediaQuery.queryAudios();

    final tracks = audios.map((audio) {
      return Track(
        id: audio.id,
        title: audio.title,
        artist: audio.artist,
        album: audio.album,
        path: audio.data,
        duration: audio.duration,
        artwork: null,
      );
    }).toList();

    return tracks;
  }
}
