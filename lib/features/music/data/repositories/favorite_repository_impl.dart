import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  static const String _favoritesKey = 'favorite_track_ids';

  @override
  Future<Set<int>> getFavoriteIds() async {
    final preferences = await SharedPreferences.getInstance();

    final savedIds = preferences.getStringList(_favoritesKey) ?? [];

    return savedIds.map((id) => int.tryParse(id)).whereType<int>().toSet();
  }

  @override
  Future<void> saveFavoriteIds(Set<int> ids) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setStringList(
      _favoritesKey,
      ids.map((id) => id.toString()).toList(),
    );
  }
}
