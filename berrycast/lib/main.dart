import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'audioplayer_stream_wrapper.dart';
import 'bloc/db_offline_episode.dart';
import 'bloc/db_podcast.dart';
import 'home.dart';
import 'model/podcast.dart';
import 'musics_provider.dart';
import 'theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioSchedule schedule = AudioSchedule();

  @override
  void initState() {
    super.initState();
    dbOfflineEpisodeBloc.init();
    FlutterDownloader.registerCallback(
        (String id, DownloadTaskStatus status, int progress) async {
      // workaround when a task is just started but no byte is downloaded, then this task is paused.
      // The flutter_downloader will return progress as -1 in this case.
      if (progress < 0) {
        progress = 0;
      }
      dbOfflineEpisodeBloc.upgradeTaskStatus(id, status, progress);
    });
  }

  @override
  void dispose() {
    FlutterDownloader.registerCallback(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioSchedule>.value(value: schedule),
        ChangeNotifierProvider<MusicProvider>.value(value: musicProvider),
        StreamProvider<AudioPosition>.value(
          value: schedule.player.onAudioPositionChanged,
          initialData: AudioPosition(Duration()),
        ),
        StreamProvider<SeekPosition>.value(
          value: schedule.player.onSeekPositionChanged,
          initialData: SeekPosition(Duration()),
        ),
//        StreamProvider<AudioDuration>.value(
//          value: schedule.player.onDurationChanged
//              .map((dur) => AudioDuration(dur)),
//          initialData: AudioDuration(Duration()),
//        ),
        StreamProvider<AudioPlayerState>.value(
          value: schedule.player.onPlayerStateChanged,
          initialData: AudioPlayerState.STOPPED,
        ),
        StreamProvider<List<Podcast>>.value(
          value: dbPodcastBloc.podcasts,
        ),
      ],
      child: MaterialApp(
        title: '',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: accentColor,
          accentColor: accentColor,
        ),
        home: Home(),
      ),
    );
  }
}
