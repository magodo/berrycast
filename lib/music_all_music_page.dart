import 'package:flutter/material.dart';

import 'model/music.dart';
import 'radial_seekbar.dart';
import 'sliver_appbar_delegate.dart';
import 'utils.dart';

class AllMusicPage extends StatefulWidget {
  final List<Music> musics;

  const AllMusicPage({Key key, this.musics}) : super(key: key);

  @override
  _AllMusicPageState createState() => _AllMusicPageState();
}

class _AllMusicPageState extends State<AllMusicPage> {
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
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
                    buildPlayallButton(context, widget.musics),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: _buildMusicListView(context),
    );
  }

  Widget _buildMusicListView(context) {
    return ListView(
      children: widget.musics.map((e) => _buildMusicItem(context, e)).toList(),
    );
  }

  Card _buildMusicItem(BuildContext context, Music e) {
    return Card(
      child: ListTile(
        leading: ClipOval(
          clipper: CircleClipper(),
          child: e.albumArt,
        ),
        onTap: () => playSong(context, e),
        title: Text(
          e.songTitle,
        ),
        subtitle: Text(e.artist + " - " + e.albumTitle),
        trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
      ),
    );
  }
}
