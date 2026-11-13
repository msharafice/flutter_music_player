import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../music/domain/entities/track.dart';
import '../../../music/presentation/providers/favorite_provider.dart';
import '../providers/player_provider.dart';

class NowPlayingPage extends ConsumerWidget {
  const NowPlayingPage({super.key});

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackControllerProvider);
    final playerState = ref.watch(playerStateStreamProvider);
    final positionAsync = ref.watch(positionStreamProvider);
    final durationAsync = ref.watch(durationStreamProvider);
    final loopAsync = ref.watch(loopModeStreamProvider);

    final track = playback.currentTrack;

    if (track == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Text(
            'No track selected.',
            style: TextStyle(color: AppColors.darkTextPrimary),
          ),
        ),
      );
    }

    final favoriteIdsAsync = ref.watch(favoriteIdsProvider);

    final isFavorite =
        favoriteIdsAsync.asData?.value.contains(track.id) ?? false;

    final controller = ref.read(playbackControllerProvider.notifier);

    final isPlaying = playerState.asData?.value.playing ?? false;
    final loopMode = loopAsync.asData?.value ?? LoopMode.off;

    final position = positionAsync.asData?.value ?? Duration.zero;

    final duration =
        durationAsync.asData?.value ?? Duration(milliseconds: track.duration);

    final maxMilliseconds = duration.inMilliseconds > 0
        ? duration.inMilliseconds.toDouble()
        : 1.0;

    final currentMilliseconds = position.inMilliseconds
        .clamp(0, maxMilliseconds.toInt())
        .toDouble();

    final upcomingTracks = playback.queue
        .skip(playback.currentIndex + 1)
        .take(2)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.darkTextPrimary,
            size: 32,
          ),
        ),
        title: const Column(
          children: [
            Text(
              'NOW PLAYING',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Music Player',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            children: [
              const SizedBox(height: 8),

              _buildArtwork(),

              const SizedBox(height: 30),

              Text(
                track.title.isEmpty ? 'Unknown track' : track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                track.artist.isEmpty ? 'Unknown artist' : track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      ref
                          .read(favoriteIdsProvider.notifier)
                          .toggleFavorite(track.id);
                    },
                    tooltip: isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite
                          ? AppColors.primaryLight
                          : AppColors.darkTextSecondary,
                      size: 27,
                    ),
                  ),

                  Text(
                    isFavorite ? 'Added to Favorites' : 'Add to Favorites',
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 15,
                  ),
                ),
                child: Slider(
                  value: currentMilliseconds,
                  min: 0,
                  max: maxMilliseconds,
                  onChanged: (value) {
                    controller.seek(Duration(milliseconds: value.round()));
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(position),
                      style: const TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      formatDuration(duration),
                      style: const TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 23),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: controller.shuffleToRandomTrack,
                    icon: const Icon(Icons.shuffle_rounded),
                    color: AppColors.darkTextSecondary,
                    iconSize: 23,
                    tooltip: 'Play a random track',
                  ),

                  IconButton(
                    onPressed: controller.previousTrack,
                    icon: const Icon(Icons.skip_previous_rounded),
                    iconSize: 37,
                    color: AppColors.darkTextPrimary,
                  ),

                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glow.withValues(alpha: 0.4),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: controller.togglePlayPause,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: controller.nextTrack,
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: 37,
                    color: AppColors.darkTextPrimary,
                  ),

                  IconButton(
                    onPressed: controller.cycleLoopMode,
                    icon: Icon(
                      loopMode == LoopMode.one
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                    ),
                    color: loopMode == LoopMode.off
                        ? AppColors.darkTextSecondary
                        : AppColors.primaryLight,
                    iconSize: 23,
                    tooltip: 'Repeat mode',
                  ),
                ],
              ),

              const SizedBox(height: 34),

              _buildUpNextSection(upcomingTracks),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 330),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withValues(alpha: 0.25),
            blurRadius: 35,
            spreadRadius: 3,
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: _buildArtworkPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildArtworkPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF30145F), Color(0xFF17132C), Color(0xFF090914)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColors.primaryLight,
          size: 115,
        ),
      ),
    );
  }

  Widget _buildUpNextSection(List<Track> tracks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Up Next',
                style: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${tracks.length} upcoming',
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontSize: 11,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (tracks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No more tracks in the queue',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 12,
              ),
            ),
          )
        else
          ...tracks.map(_buildQueueTrack),
      ],
    );
  }

  Widget _buildQueueTrack(Track track) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: AppColors.primaryLight,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title.isEmpty ? 'Unknown track' : track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  track.artist.isEmpty ? 'Unknown artist' : track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.queue_music_rounded,
            color: AppColors.darkTextSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
