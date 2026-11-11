
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_music_player/app/app.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MusicPlayerApp(),
      ),
    );

    expect(find.text('Flutter Music Player'), findsOneWidget);
  });
}
