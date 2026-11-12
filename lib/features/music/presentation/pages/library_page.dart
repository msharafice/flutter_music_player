import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import '../../domain/entities/track.dart';
import '../providers/track_provider.dart';
import '../widgets/track_tile.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Track> _filterTracks(List<Track> tracks) {
    if (_searchQuery.trim().isEmpty) {
      return tracks;
    }

    final query = _searchQuery.toLowerCase().trim();

    return tracks.where((track) {
      return track.title.toLowerCase().contains(query) ||
          track.artist.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _playTrack(Track track, List<Track> tracks) async {
    await ref
        .read(playbackControllerProvider.notifier)
        .playTrack(track, tracks);
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,

      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(child: _buildHeader()),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _buildHeroBanner(tracksAsync)),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              sliver: SliverToBoxAdapter(child: _buildSearchField()),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(tracksAsync),
              ),
            ),

            ...tracksAsync.when<List<Widget>>(
              data: (tracks) {
                final filteredTracks = _filterTracks(tracks);

                if (filteredTracks.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(
                        tracks.isEmpty
                            ? 'No music found on your device.'
                            : 'No matching songs found.',
                        tracks.isEmpty
                            ? Icons.music_off_rounded
                            : Icons.search_off_rounded,
                      ),
                    ),
                  ];
                }

                return [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final track = filteredTracks[index];

                        return TrackTile(
                          track: track,
                          onTap: () => _playTrack(track, tracks),
                        );
                      }, childCount: filteredTracks.length),
                    ),
                  ),
                ];
              },

              loading: () => [
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ],

              error: (error, stackTrace) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            size: 35,
            color: AppColors.primaryLight,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Music Player', style: AppTextStyles.heading),

              const SizedBox(height: 4),

              Text(
                'Your Music. Your Mood.',
                style: AppTextStyles.subtitle.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),

        _headerIcon(icon: Icons.settings_outlined, onTap: () {}),
      ],
    );
  }

  Widget _headerIcon({required IconData icon, required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.darkTextSecondary, size: 25),
    );
  }

  Widget _buildHeroBanner(AsyncValue<List<Track>> tracksAsync) {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF7437EF), Color(0xFF4D42C8), Color(0xFF2458B7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            bottom: -65,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned(
            right: 25,
            top: -35,
            child: Icon(
              Icons.headphones_rounded,
              size: 145,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enjoy Your Music!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Every moment has its own sound.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),

                const SizedBox(height: 15),

                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: () {
                      tracksAsync.whenData((tracks) {
                        if (tracks.isNotEmpty) {
                          _playTrack(tracks.first, tracks);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 9,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Play Music',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search songs, artists...',
          hintStyle: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryLight,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AsyncValue<List<Track>> tracksAsync) {
    final count = tracksAsync.asData?.value.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Your Music', style: AppTextStyles.sectionTitle),

        if (count != null)
          Text(
            '$count tracks',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.primaryLight,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load music.',
              style: TextStyle(color: AppColors.darkTextPrimary),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: () {
                ref.invalidate(tracksProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
