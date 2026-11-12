import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../music/domain/entities/track.dart';
import '../../data/datasources/audio_player_data_source.dart';

final audioPlayerDataSourceProvider = Provider<AudioPlayerDataSource>((ref) {
  final dataSource = AudioPlayerDataSource();

  ref.onDispose(() {
    dataSource.dispose();
  });

  return dataSource;
});

final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(audioPlayerDataSourceProvider).player.playerStateStream;
});

final positionStreamProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerDataSourceProvider).player.positionStream;
});

final durationStreamProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(audioPlayerDataSourceProvider).player.durationStream;
});

class PlaybackState {
  final List<Track> queue;
  final int currentIndex;
  final String? error;

  const PlaybackState({
    this.queue = const [],
    this.currentIndex = 0,
    this.error,
  });

  Track? get currentTrack {
    if (queue.isEmpty || currentIndex < 0 || currentIndex >= queue.length) {
      return null;
    }

    return queue[currentIndex];
  }

  PlaybackState copyWith({
    List<Track>? queue,
    int? currentIndex,
    String? error,
    bool clearError = false,
  }) {
    return PlaybackState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final playbackControllerProvider =
    NotifierProvider<PlaybackController, PlaybackState>(PlaybackController.new);

class PlaybackController extends Notifier<PlaybackState> {
  @override
  PlaybackState build() {
    final dataSource = ref.read(audioPlayerDataSourceProvider);

    final subscription = dataSource.player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < state.queue.length) {
        state = state.copyWith(currentIndex: index);
      }
    });

    ref.onDispose(subscription.cancel);

    return const PlaybackState();
  }

  Future<void> playTrack(Track track, List<Track> tracks) async {
    if (tracks.isEmpty) return;

    final index = tracks.indexWhere((item) => item.id == track.id);

    if (index == -1) return;

    state = state.copyWith(
      queue: List<Track>.unmodifiable(tracks),
      currentIndex: index,
      clearError: true,
    );

    try {
      await ref.read(audioPlayerDataSourceProvider).playTracks(tracks, index);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> togglePlayPause() async {
    await ref.read(audioPlayerDataSourceProvider).toggle();
  }

  Future<void> nextTrack() async {
    await ref.read(audioPlayerDataSourceProvider).next();
  }

  Future<void> previousTrack() async {
    await ref.read(audioPlayerDataSourceProvider).previous();
  }

  Future<void> seek(Duration position) async {
    await ref.read(audioPlayerDataSourceProvider).seek(position);
  }
}
