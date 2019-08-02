import 'package:audioplayers/audioplayers.dart';
import 'package:berrycast/buttom_controls.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'album.dart';
import 'album_page.dart';
import 'audio.dart';
import 'audioplayer_stream_wrapper.dart';
import 'radial_seekbar.dart';
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
          primarySwatch: Colors.blue,
        ),
        home: ChangeNotifierProvider<DemoAlbumList>.value(
          value: demoAlbumList,
          child: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  _openAlbumPage(BuildContext context, DemoAlbum album) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AlbumPage(album: album);
    }));
  }

  List<Widget> _buildAlbumThumb(BuildContext context) {
    final albumList = Provider.of<DemoAlbumList>(context);
    return List.generate(
      albumList.albums.length,

      (idx) => RawMaterialButton(
        shape: CircleBorder(),
        splashColor: lightAccentColor,
        highlightColor: lightAccentColor.withOpacity(0.5),
        elevation: 10.0,
        highlightElevation: 5.0,
        onPressed: () {},
        child: GridTile(
          child: InkResponse(
            enableFeedback: true,
            child: Image.network(
              albumList.albums[idx].albumArtUrl,
              fit: BoxFit.cover,
            ),
            onTap: () => _openAlbumPage(context, albumList.albums[idx]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          padding: const EdgeInsets.all(4.0),
          childAspectRatio: 1.0,
          children: _buildAlbumThumb(context)),
    );
  }
}

