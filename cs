warning: in the working copy of 'lib/features/music/data/repositories/track_repository_impl.dart', LF will be replaced by CRLF the next time Git touches it
[1mdiff --git a/lib/features/music/data/repositories/track_repository_impl.dart b/lib/features/music/data/repositories/track_repository_impl.dart[m
[1mindex 554c3a2..230b9dc 100644[m
[1m--- a/lib/features/music/data/repositories/track_repository_impl.dart[m
[1m+++ b/lib/features/music/data/repositories/track_repository_impl.dart[m
[36m@@ -1,3 +1,4 @@[m
[32m+[m
 import 'package:media_browser/simple_audio_query.dart';[m
 import 'package:permission_handler/permission_handler.dart';[m
 [m
[36m@@ -26,7 +27,7 @@[m [mclass TrackRepositoryImpl implements TrackRepository {[m
 [m
     final audios = await _mediaQuery.queryAudios();[m
 [m
[31m-    return audios.map((audio) {[m
[32m+[m[32m    final tracks = audios.map((audio) {[m
       return Track([m
         id: audio.id,[m
         title: audio.title,[m
[36m@@ -34,8 +35,10 @@[m [mclass TrackRepositoryImpl implements TrackRepository {[m
         album: audio.album,[m
         path: audio.data,[m
         duration: audio.duration,[m
[31m-        artwork: audio.artwork,[m
[32m+[m[32m        artwork: null,[m
       );[m
     }).toList();[m
[32m+[m
[32m+[m[32m    return tracks;[m
   }[m
 }[m
