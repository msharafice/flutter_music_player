import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../music/domain/entities/track.dart';

class AudioPlayerDataSource {
  final AudioPlayer player = AudioPlayer();

  final Random _random = Random();

  Future<void> playTracks(List<Track> tracks, int initialIndex) async {
    final session = await AudioSession.instance;

    await session.configure(const AudioSessionConfiguration.music());

    await session.setActive(true);

    final sources = tracks.map((track) {
      return AudioSource.file(
        track.path,
        tag: MediaItem(
          id: track.id.toString(),
          title: track.title.isEmpty ? 'Unknown track' : track.title,
          artist: track.artist.isEmpty ? 'Unknown artist' : track.artist,
          album: track.album,
        ),
      );
    }).toList();

    await player.setAudioSources(sources, initialIndex: initialIndex);

    await player.play();
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> toggle() async {
    if (player.playing) {
      await pause();
    } else {
      if (player.processingState == ProcessingState.completed) {
        await player.seek(Duration.zero);
      }

      await play();
    }
  }

  Future<void> next() async {
    if (player.hasNext) {
      await player.seekToNext();
    }
  }

  Future<void> previous() async {
    if (player.position.inSeconds > 3) {
      await player.seek(Duration.zero);
    } else if (player.hasPrevious) {
      await player.seekToPrevious();
    }
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> playRandomTrack(int queueLength) async {
    if (queueLength < 2) return;

    // Make sure the persistent shuffle mode is disabled.
    if (player.shuffleModeEnabled) {
      await player.setShuffleModeEnabled(false);
    }

    final currentIndex = player.currentIndex ?? 0;

    // Generate a random index different from the current one.
    var randomIndex = _random.nextInt(queueLength - 1);

    if (randomIndex >= currentIndex) {
      randomIndex++;
    }

    await player.seek(Duration.zero, index: randomIndex);

    await player.play();
  }

  Future<void> cycleLoopMode() async {
    final LoopMode nextMode;

    switch (player.loopMode) {
      case LoopMode.off:
        nextMode = LoopMode.all;
        break;

      case LoopMode.all:
        nextMode = LoopMode.one;
        break;

      case LoopMode.one:
        nextMode = LoopMode.off;
        break;
    }

    await player.setLoopMode(nextMode);
  }

  Future<void> dispose() async {
    await player.dispose();
  }
}
