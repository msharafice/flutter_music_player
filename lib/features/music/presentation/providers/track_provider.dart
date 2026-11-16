
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_browser/simple_audio_query.dart';

import '../../data/datasources/local_audio_data_source.dart';
import '../../data/repositories/track_repository_impl.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';

final mediaQueryProvider = Provider<SimpleMediaQuery>((ref) {
  return SimpleMediaQuery();
});

final localAudioDataSourceProvider =
    Provider<LocalAudioDataSource>((ref) {
  final mediaQuery = ref.watch(mediaQueryProvider);

  return LocalAudioDataSource(mediaQuery);
});

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  final dataSource = ref.watch(localAudioDataSourceProvider);

  return TrackRepositoryImpl(dataSource);
});

final tracksProvider = FutureProvider<List<Track>>((ref) async {
  final repository = ref.watch(trackRepositoryProvider);

  return repository.getTracks();
});
