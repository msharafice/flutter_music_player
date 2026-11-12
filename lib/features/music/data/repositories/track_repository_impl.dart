
import 'package:media_browser/media_browser.dart';
import 'package:media_browser/simple_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';

class TrackRepositoryImpl implements TrackRepository {
  final SimpleMediaQuery _mediaQuery;

  TrackRepositoryImpl(this._mediaQuery);

  @override
  Future<List<Track>> getTracks() async {
    print('getTracks() called');

    try {
      // Step 1: Request audio permission directly.
      print('Requesting audio permission...');

      final permissionStatus = await Permission.audio.request();

      print('Permission status: $permissionStatus');

      // Step 2: Check permission result.
      if (!permissionStatus.isGranted) {
        if (permissionStatus.isPermanentlyDenied) {
          throw Exception(
            'Audio permission is permanently denied. '
            'Please enable it in app settings.',
          );
        }

        throw Exception(
          'Audio permission was denied: $permissionStatus',
        );
      }

      print('Audio permission granted');

      // Step 3: Query audio files.
      final audios = await _mediaQuery.queryAudios();

      print('Found ${audios.length} audio files');

      // Step 4: Convert audio files to Track entities.
      final tracks = audios.map((audio) {
        return Track(
          id: audio.id,
          title: audio.title,
          artist: audio.artist,
          album: audio.album,
          path: audio.data,
          duration: audio.duration,
          artwork: audio.artwork,
        );
      }).toList();

      return tracks;
    } catch (e, stackTrace) {
      print('Error in getTracks(): $e');
      print(stackTrace);
      rethrow;
    }
  }
}
