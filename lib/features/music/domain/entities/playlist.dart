class Playlist {
  final String id;
  final String name;
  final List<int> trackIds;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.createdAt,
  });

  Playlist copyWith({String? name, List<int>? trackIds}) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt,
    );
  }
}
