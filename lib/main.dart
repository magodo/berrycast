import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'audioplayer_stream_wrapper.dart';
import 'home_page.dart';
import 'songs.dart';
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
          value: schedule.player.onAudioPositionChanged
              .map((position) => AudioPosition(position)),
          initialData: AudioPosition(Duration()),
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
      ],
      child: MaterialApp(
        title: '',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: accentColor,
        ),
        home: ChangeNotifierProvider<DemoAlbumList>.value(
          value: demoAlbumList,
          child: HomePage(),
        ),
      ),
    );
  }
}