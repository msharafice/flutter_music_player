
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';
import '../datasources/local_audio_data_source.dart';
import '../models/track_model.dart';

class TrackRepositoryImpl implements TrackRepository {
  final LocalAudioDataSource _dataSource;

  TrackRepositoryImpl(this._dataSource);

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

      throw Exception(
        'Audio permission was denied: $permissionStatus',
      );
    }

    final audios = await _dataSource.getAudios();

    final tracks = audios.map((audio) {
      return TrackModel.fromAudioModel(audio).toEntity();
    }).toList();

    return tracks;
  }
}
