import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'audioplayer_stream_wrapper.dart';
import 'bloc/db_podcast.dart';
import 'home.dart';
import 'model/podcast.dart';
import 'theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final AudioSchedule schedule = AudioSchedule();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioSchedule>.value(value: schedule),
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

