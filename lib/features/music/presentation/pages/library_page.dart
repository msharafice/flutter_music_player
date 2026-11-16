
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import '../../domain/entities/track.dart';
import '../providers/track_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/track_tile.dart';
import 'favorites_page.dart';
import 'playlists_page.dart';
import 'history_page.dart';

enum TrackSortOption {
  dateAdded,
  nameAZ,
  nameZA,
  artist,
  album,
  duration,
  year,
  size,
  random,
  dateModified,
}

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  TrackSortOption _sortOption = TrackSortOption.nameAZ;

  String? _selectedArtist;
  String? _selectedAlbum;

  List<int> _randomTrackIds = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _compareDateNewest(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    return b.compareTo(a);
  }

  int _compareIntDescending(int? a, int? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    return b.compareTo(a);
  }

  List<Track> _filterAndSortTracks(List<Track> tracks) {
    final query = _searchQuery.trim().toLowerCase();

    final result = tracks.where((track) {
      final matchesSearch = query.isEmpty ||
          track.title.toLowerCase().contains(query) ||
          track.artist.toLowerCase().contains(query) ||
          track.album.toLowerCase().contains(query);

      final matchesArtist =
          _selectedArtist == null || track.artist == _selectedArtist;

      final matchesAlbum =
          _selectedAlbum == null || track.album == _selectedAlbum;

      return matchesSearch && matchesArtist && matchesAlbum;
    }).toList();

    switch (_sortOption) {
      case TrackSortOption.dateAdded:
        result.sort(
          (a, b) => _compareDateNewest(
            a.dateAdded,
            b.dateAdded,
          ),
        );
        break;

      case TrackSortOption.nameAZ:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(
                b.title.toLowerCase(),
              ),
        );
        break;

      case TrackSortOption.nameZA:
        result.sort(
          (a, b) => b.title.toLowerCase().compareTo(
                a.title.toLowerCase(),
              ),
        );
        break;

      case TrackSortOption.artist:
        result.sort(
          (a, b) => a.artist.toLowerCase().compareTo(
                b.artist.toLowerCase(),
              ),
        );
        break;

      case TrackSortOption.album:
        result.sort(
          (a, b) => a.album.toLowerCase().compareTo(
                b.album.toLowerCase(),
              ),
        );
        break;

      case TrackSortOption.duration:
        result.sort(
          (a, b) => a.duration.compareTo(b.duration),
        );
        break;

      case TrackSortOption.year:
        result.sort(
          (a, b) => _compareIntDescending(a.year, b.year),
        );
        break;

      case TrackSortOption.size:
        result.sort(
          (a, b) => b.fileSize.compareTo(a.fileSize),
        );
        break;

      case TrackSortOption.dateModified:
        result.sort(
          (a, b) => _compareDateNewest(
            a.dateModified,
            b.dateModified,
          ),
        );
        break;

      case TrackSortOption.random:
        final order = {
          for (var i = 0; i < _randomTrackIds.length; i++)
            _randomTrackIds[i]: i,
        };

        result.sort(
          (a, b) => (order[a.id] ?? 999999).compareTo(
            order[b.id] ?? 999999,
          ),
        );
        break;
    }

    return result;
  }

  void _changeSortOption(
    TrackSortOption option,
    List<Track> tracks,
  ) {
    setState(() {
      _sortOption = option;

      if (option == TrackSortOption.random) {
        _randomTrackIds = tracks.map((track) => track.id).toList()
          ..shuffle();
      }
    });
  }

  Future<void> _playTrack(Track track, List<Track> tracks) async {
    await ref
        .read(playbackControllerProvider.notifier)
        .playTrack(track, tracks);
  }

  Future<void> _openFilterSheet(List<Track> tracks) async {
    String? tempArtist = _selectedArtist;
    String? tempAlbum = _selectedAlbum;

    final artists = tracks
        .map((track) => track.artist)
        .where((artist) => artist.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final albums = tracks
        .map((track) => track.album)
        .where((album) => album.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_list_rounded,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Filter Music',
                            style: AppTextStyles.sectionTitle,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _buildFilterDropdown(
                      label: 'Artist',
                      hint: 'All artists',
                      value: tempArtist,
                      items: artists,
                      onChanged: (value) {
                        setSheetState(() => tempArtist = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildFilterDropdown(
                      label: 'Album',
                      hint: 'All albums',
                      value: tempAlbum,
                      items: albums,
                      onChanged: (value) {
                        setSheetState(() => tempAlbum = value);
                      },
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                tempArtist = null;
                                tempAlbum = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryLight,
                              side: const BorderSide(
                                color: AppColors.primary,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedArtist = tempArtist;
                                _selectedAlbum = tempAlbum;
                              });

                              Navigator.pop(sheetContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.6),
            ),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: Text(
              hint,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 13,
              ),
            ),
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.darkSurface,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryLight,
            ),
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 14,
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(hint),
              ),
              ...items.map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: _buildHeader(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildHeroBanner(tracksAsync),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              sliver: SliverToBoxAdapter(
                child: _buildSearchField(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildLibraryControls(tracksAsync),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(tracksAsync),
              ),
            ),
            ...tracksAsync.when<List<Widget>>(
              data: (tracks) {
                final filteredTracks = _filterAndSortTracks(tracks);

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
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final track = filteredTracks[index];

                          return TrackTile(
                            track: track,
                            isFavorite:
                                favoriteIdsAsync.asData?.value.contains(
                                      track.id,
                                    ) ??
                                    false,
                            onTap: () {
                              _playTrack(track, tracks);
                            },
                            onFavoriteTap: () {
                              ref
                                  .read(favoriteIdsProvider.notifier)
                                  .toggleFavorite(track.id);
                            },
                          );
                        },
                        childCount: filteredTracks.length,
                      ),
                    ),
                  ),
                ];
              },
              loading: () => [
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
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

  Widget _buildLibraryControls(AsyncValue<List<Track>> tracksAsync) {
    final tracks = tracksAsync.asData?.value;

    final hasActiveFilters =
        _selectedArtist != null || _selectedAlbum != null;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12, right: 6),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sort_rounded,
                size: 19,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 6),
              DropdownButton<TrackSortOption>(
                value: _sortOption,
                underline: const SizedBox(),
                dropdownColor: AppColors.darkSurface,
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 12,
                ),
                items: const [
                  DropdownMenuItem(
                    value: TrackSortOption.dateAdded,
                    child: Text('Date Added'),
                  ),
                  DropdownMenuItem(
                    value: TrackSortOption.nameAZ,
                    child: Text('Name A-Z'),
                  ),
                  DropdownMenuItem(
                    value: TrackSortOption.nameZA,
                    child: Text('Name Z-A'),
                  ),
                  DropdownMenuItem(
                    value: TrackSortOption.artist,
                    child: Text('Artist'),
                  ),
                  DropdownMenuItem(
                    value: TrackSortOption.album,
                    child: Text('Album'),
                  ),
                  DropdownMenuItem(
                    value: TrackSortOption.duration,
                    child: Text('Duration'),
                  ),
                  DropdownMenuItem(
                    value: TrackSortOption.year,
                    child: Text('Year'),
                  ),
                  DropdownMenuItem(
                    value: TrackSortOption.size,
                    child: Text('Size'),
                  ),
                  DropdownMenuItem(
                    value: TrackSortOption.random,
                    child: Text('Random'),
                  ),
                  DropdownMenuItem(
                    value: TrackSortOption.dateModified,
                    child: Text('Date Modified'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null && tracks != null) {
                    _changeSortOption(value, tracks);
                  }
                },
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: tracks == null || tracks.isEmpty
              ? null
              : () => _openFilterSheet(tracks),
          style: OutlinedButton.styleFrom(
            foregroundColor: hasActiveFilters
                ? Colors.white
                : AppColors.primaryLight,
            backgroundColor: hasActiveFilters
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.darkSurface,
            side: BorderSide(
              color: hasActiveFilters
                  ? AppColors.primary
                  : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          icon: const Icon(Icons.filter_list_rounded, size: 19),
          label: Text(
            hasActiveFilters ? 'Filtered' : 'Filter',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
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
              const Text(
                'Music Player',
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 4),
              Text(
                'Your Music. Your Mood.',
                style: AppTextStyles.subtitle.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        _headerIcon(
          icon: Icons.queue_music_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PlaylistsPage(),
              ),
            );
          },
        ),
        _headerIcon(
          icon: Icons.history_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HistoryPage(),
              ),
            );
          },
        ),
        _headerIcon(
          icon: Icons.favorite_border_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FavoritesPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _headerIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: AppColors.darkTextSecondary,
        size: 25,
      ),
    );
  }

  Widget _buildHeroBanner(AsyncValue<List<Track>> tracksAsync) {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7437EF),
            Color(0xFF4D42C8),
            Color(0xFF2458B7),
          ],
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
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
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 14,
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Search songs, artists, albums...',
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
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AsyncValue<List<Track>> tracksAsync) {
    final tracks = tracksAsync.asData?.value;

    if (tracks == null) {
      return const Text(
        'Your Music',
        style: AppTextStyles.sectionTitle,
      );
    }

    final visibleCount = _filterAndSortTracks(tracks).length;

    final hasActiveSearch = _searchQuery.trim().isNotEmpty;
    final hasActiveFilters =
        _selectedArtist != null || _selectedAlbum != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Music',
          style: AppTextStyles.sectionTitle,
        ),
        Text(
          hasActiveSearch || hasActiveFilters
              ? '$visibleCount of ${tracks.length} tracks'
              : '${tracks.length} tracks',
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
            Icon(
              icon,
              size: 58,
              color: AppColors.primaryLight,
            ),
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
              style: TextStyle(
                color: AppColors.darkTextPrimary,
              ),
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
