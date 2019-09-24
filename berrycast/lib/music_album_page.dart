import 'package:flutter/material.dart';

import 'bottom_bar.dart';
import 'model/music.dart';
import 'sliver_appbar_delegate.dart';
import 'utils.dart';

class AlbumPage extends StatefulWidget {
  final List<Music> albumMusics;

  AlbumPage({Key key, this.albumMusics}) : super(key: key) {
    albumMusics.sort((m1, m2) => m1.trackId - m2.trackId);
  }

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
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
                  background: widget.albumMusics[0].albumArt,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        buildPlayallButton(context, widget.albumMusics),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: buildMusicListView(context),
        ),
        bottomNavigationBar: BottomBar(),
      ),
    );
  }

  Widget buildMusicListView(BuildContext context) {
    return ListView(
      children: widget.albumMusics
          .asMap()
          .map((idx, music) =>
              MapEntry(idx, MusicItem(index: idx, music: music)))
          .values
          .toList(),
    );
  }
}

class MusicItem extends StatelessWidget {
  final int index;
  final Music music;

  const MusicItem({Key key, this.index, this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text("$index"),
      title: Text(music.songTitle,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          )),
      subtitle: Text(music.artist + " - " + music.albumTitle),
      onTap: () => playSong(context, music),
    );
  }
}
