
import 'package:media_browser/media_browser.dart';

import '../../domain/entities/track.dart';

class TrackModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final int duration;
  final String? artwork;
  final DateTime? dateAdded;
  final int? year;
  final int fileSize;
  final DateTime? dateModified;

  const TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
    this.artwork,
    this.dateAdded,
    this.year,
    this.fileSize = 0,
    this.dateModified,
  });

  factory TrackModel.fromAudioModel(AudioModel audio) {
    DateTime? convertTimestamp(int timestamp) {
      if (timestamp <= 0) return null;

      return DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000,
      );
    }

    return TrackModel(
      id: audio.id,
      title: audio.title,
      artist: audio.artist,
      album: audio.album,
      path: audio.data,
      duration: audio.duration,
      artwork: audio.artwork,
      dateAdded: convertTimestamp(audio.dateAdded),
      year: audio.year > 0 ? audio.year : null,
      fileSize: audio.size,
      dateModified: convertTimestamp(audio.dateModified),
    );
  }

  Track toEntity() {
    return Track(
      id: id,
      title: title,
      artist: artist,
      album: album,
      path: path,
      duration: duration,
      artwork: artwork,
      dateAdded: dateAdded,
      year: year,
      fileSize: fileSize,
      dateModified: dateModified,
    );
  }
}
