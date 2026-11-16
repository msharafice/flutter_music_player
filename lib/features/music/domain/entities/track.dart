
class Track {
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

  const Track({
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
}
