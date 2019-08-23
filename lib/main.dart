import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'audioplayer_stream_wrapper.dart';
import 'bloc/db_podcast.dart';
import 'bottom_bar.dart';
import 'model/podcast.dart';
import 'podcast_page.dart';
import 'search_page.dart';
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
        home: DefaultTabController(
          initialIndex: 0,
          length: 3,
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  "Berrycast",
                  style: TextStyle(color: Colors.white),
                ),
                leading: Builder(builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.menu),
                    color: Colors.white,
                    onPressed: Scaffold.of(context).openDrawer,
                  );
                }),
                bottom: TabBar(tabs: [
                  Tab(icon: Icon(Icons.cast)),
                  Tab(icon: Icon(Icons.library_music)),
                  Tab(icon: Icon(Icons.search)),
                ]),
              ),
              drawer: Drawer(
                child: Container(),
              ),
              body: TabBarView(
                children: [
                  PodcastPage(),
                  Container(),
                  SearchPage(),
                ],
              ),
              bottomSheet: BottomBar(),
            ),
          ),
        ),
      ),
    );
  }
}
