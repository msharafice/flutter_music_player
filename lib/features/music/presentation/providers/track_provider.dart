import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_browser/simple_audio_query.dart';

import '../../data/repositories/track_repository_impl.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';

final mediaQueryProvider = Provider<SimpleMediaQuery>((ref) {
  return SimpleMediaQuery();
});

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  final mediaQuery = ref.watch(mediaQueryProvider);

  return TrackRepositoryImpl(mediaQuery);
});

final tracksProvider = FutureProvider<List<Track>>((ref) async {
  final repository = ref.watch(trackRepositoryProvider);

  return repository.getTracks();
});