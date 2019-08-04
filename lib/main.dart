import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'audioplayer_stream_wrapper.dart';
import 'bottom_bar.dart';
import 'podcast_page.dart';
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
          child: DefaultTabController(
            length: 3,
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
                  Tab(
                    icon: Icon(Icons.find_replace),
                  ),
                ]),
              ),
              drawer: SafeArea(
                child: Drawer(
                  child: Container(),
                ),
              ),
              body: TabBarView(children: [
                PodcastPage(),
                Container(),
                Container(),
              ]),
              bottomSheet: BottomBar(),
            ),
          ),
        ),
      ),
    );
  }
}
