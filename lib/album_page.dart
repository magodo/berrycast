import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'bottom_bar.dart';
import 'play_page.dart';
import 'sliver_appbar_delegate.dart';
import 'songs.dart';

class AlbumPage extends StatelessWidget {
  final Album album;

  const AlbumPage({Key key, this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: true,
                snap: false,
                pinned: true,
                elevation: 0.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: album.albumArt,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverAppBarDelegate(
                  minHeight: 50.0,
                  maxHeight: 50.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: FlatButton(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.play_circle_outline),
                          ),
                          Text("PLAY ALL (${album.songs.length})"),
                        ],
                      ),
                      onPressed: () => _playNewAlbumm(context, album),
                    ),
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
        bottomSheet: BottomBar(),
      ),
    );
  }

  ListTile _buildSongTile(BuildContext context, int index, Episode song) {
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

  _playNewSong(BuildContext context, Episode song) {
    final schedule = Provider.of<AudioSchedule>(context);
    schedule.playlist = <Episode>[song];
    schedule.playNthSong(0);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayPage();
    }));
  }

  _playNewAlbumm(BuildContext context, PodcastAlbum album) {
    final schedule = Provider.of<AudioSchedule>(context);
    schedule.playlist = List.from(album.songs);
    schedule.playNthSong(0);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayPage();
    }));
  }
}
