import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'album.dart';
import 'audio.dart';
import 'play_page.dart';
import 'songs.dart';

class AlbumPage extends StatelessWidget {
  final DemoAlbum album;

  const AlbumPage({Key key, this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
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
                .map((DemoSong song) => _buildSongTile(context, song))
                .toList(),
          ),
        ),
      ),
    );
  }

  ListTile _buildSongTile(BuildContext context, DemoSong song) {
    return ListTile(
      title: Text(song.songTitle,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(song.artist),
      onTap: () => _openPlayPage(context, song),
    );
  }

  _openPlayPage(BuildContext context, DemoSong song) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      final schedule = Provider.of<AudioSchedule>(context);
      schedule.playlist = DemoPlaylist(songs: <DemoSong>[song]);
      schedule.play();
      return PlayPage();
    }));
  }
}
