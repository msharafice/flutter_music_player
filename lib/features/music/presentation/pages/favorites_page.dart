import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import '../../domain/entities/track.dart';
import '../providers/favorite_provider.dart';
import '../providers/track_provider.dart';
import '../widgets/track_tile.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  Future<void> _playTrack(
    WidgetRef ref,
    Track track,
    List<Track> tracks,
  ) async {
    await ref
        .read(playbackControllerProvider.notifier)
        .playTrack(track, tracks);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(tracksProvider);
    final favoriteIdsAsync = ref.watch(favoriteIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Favorites', style: AppTextStyles.heading),
                    ),
                    const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.primaryLight,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),

            tracksAsync.when(
              data: (tracks) {
                return favoriteIdsAsync.when(
                  data: (favoriteIds) {
                    final favoriteTracks = tracks
                        .where((track) => favoriteIds.contains(track.id))
                        .toList();

                    if (favoriteTracks.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final track = favoriteTracks[index];

                          return TrackTile(
                            track: track,
                            isFavorite: true,
                            onTap: () {
                              _playTrack(ref, track, favoriteTracks);
                            },
                            onFavoriteTap: () {
                              ref
                                  .read(favoriteIdsProvider.notifier)
                                  .toggleFavorite(track.id);
                            },
                          );
                        }, childCount: favoriteTracks.length),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  error: (error, stackTrace) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 75,
              color: AppColors.primaryLight.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            const Text(
              'No favorites yet',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Tap the heart icon on a song to add it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Unable to load favorites.',
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
      ),
    );
  }
}
