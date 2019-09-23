import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'model/music.dart';
import 'musics_provider.dart';
import 'radial_seekbar.dart';
import 'sliver_appbar_delegate.dart';
import 'utils.dart';

class AllMusicPage extends StatefulWidget {
  @override
  _AllMusicPageState createState() => _AllMusicPageState();
}

class _AllMusicPageState extends State<AllMusicPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MusicProvider>(context);
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
                    buildPlayallButton(context, mp.musics),
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
    final mp = Provider.of<MusicProvider>(context);
    final musics = mp.musics;
    musics.sort((m1, m2) => m1.songTitle.compareTo(m2.songTitle));
    return SmartRefresher(
      enablePullDown: true,
      header: MaterialClassicHeader(),
      controller: _refreshController,
      onRefresh: () async {
        await mp.updateAllSongs();
        _refreshController.refreshCompleted();
      },
      child: ListView(
        children: musics.map((e) => _buildMusicItem(context, e)).toList(),
      ),
    );
  }

  Card _buildMusicItem(BuildContext context, Music e) {
    return Card(
      child: ListTile(
        leading: ClipOval(
          clipper: CircleClipper(),
          child: e.albumArt,
        ),
        onTap: () {
          playSong(context, e);
        },
        title: Text(
          e.songTitle,
        ),
        subtitle: Text(e.artist + " - " + e.albumTitle),
      ),
    );
  }
}
