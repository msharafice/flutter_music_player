
import 'package:media_browser/media_browser.dart';
import 'package:media_browser/simple_audio_query.dart';

class LocalAudioDataSource {
  final SimpleMediaQuery _mediaQuery;

  LocalAudioDataSource(this._mediaQuery);

  Future<List<AudioModel>> getAudios() async {
    return _mediaQuery.queryAudios();
  }
}
