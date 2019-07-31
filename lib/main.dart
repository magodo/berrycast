import 'package:audioplayers/audioplayers.dart';
import 'package:berrycast/buttom_controls.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'radial_seekbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioSchedule schedule = AudioSchedule();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioSchedule>.value(value: schedule),
        StreamProvider<Duration>.value(
          value: schedule.player.onAudioPositionChanged,
          initialData: Duration(),
        ),
        StreamProvider<AudioPlayerState>.value(
          value: schedule.player.onPlayerStateChanged,
          initialData: AudioPlayerState.STOPPED,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.grey,
            onPressed: () {},
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              color: Colors.grey,
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            // seek bar
            Expanded(
              child: RadialSeekBar(),
            ),

            // visualizer
            Container(
              width: double.infinity,
              height: 125.0,
            ),

            // song title, artist name and controls
            ButtonControls(),
          ],
        ),
      ),
    );
  }
}
