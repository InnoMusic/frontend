import 'ui/innomusic_podcast_app.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'core/chrome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: - ${record.time}: ${record.loggerName}: ${record.message}');
  });

  Chrome.transparentLight();

  runApp(InnoMusicPodcastApp.InnoMusicApp());
}
