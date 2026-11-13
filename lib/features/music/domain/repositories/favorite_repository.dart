abstract class FavoriteRepository {
  Future<Set<int>> getFavoriteIds();

  Future<void> saveFavoriteIds(Set<int> ids);
}
