import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'play_page.dart';
import 'songs.dart';
import 'theme.dart';

class AlbumPage extends StatelessWidget {
  final DemoAlbum album;

  const AlbumPage({Key key, this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: lightAccentColor,
        icon: Icon(
          Icons.play_circle_outline,
        ),
        label: Text("Play All"),
        onPressed: () => _playNewAlbumm(context, album),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 200.0,
                floating: true,
                snap: false,
                elevation: 0.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    album.albumArtUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ];
          },
          body: ListView(
            children: album.songs
                .asMap()
                .map((idx, song) =>
                    MapEntry(idx, _buildSongTile(context, idx, song)))
                .values
                .toList(),
          ),
        ),
      ),
    );
  }

  ListTile _buildSongTile(BuildContext context, int index, DemoSong song) {
    return ListTile(
      leading: Text("$index"),
      title: Text(song.songTitle,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          )),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {},
      ),
      onTap: () => _playNewSong(context, song),
    );
  }

  _playNewSong(BuildContext context, DemoSong song) {
    final schedule = Provider.of<AudioSchedule>(context);
    schedule.playlist = <DemoSong>[song];
    schedule.play();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayPage();
    }));
  }

  _playNewAlbumm(BuildContext context, DemoAlbum album) {
    final schedule = Provider.of<AudioSchedule>(context);
    schedule.playlist = List.from(album.songs);
    schedule.play();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayPage();
    }));
  }
}
