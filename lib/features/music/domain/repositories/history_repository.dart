
import '../entities/track.dart';

abstract class HistoryRepository {
  Future<List<Track>> getHistory();

  Future<void> saveHistory(List<Track> tracks);

  Future<void> clearHistory();
}
