import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'play_page.dart';
import 'resources/musics_provider.dart';
import 'sliver_appbar_delegate.dart';
import 'utils.dart';

class MusicFolderPage extends StatefulWidget {
  const MusicFolderPage({Key key}) : super(key: key);

  @override
  _MusicFolderPageState createState() =>
      _MusicFolderPageState(musicProvider.musicCommonAncientDir);
}

class _MusicFolderPageState extends State<MusicFolderPage> {
  String path;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _MusicFolderPageState(this.path);

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MusicProvider>(context);
    if (path == null) {
      return Center(child: Text("no music available"));
    }
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
                  color: Colors.grey[100],
                ),
                child: Row(
                  children: <Widget>[
                    // first directory level
                    path == mp.musicCommonAncientDir
                        ? Container()
                        : IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              setState(() {
                                path = p.dirname(path);
                              });
                            },
                          ),
                    Expanded(
                        child: Center(
                            child: Text(
                      "${p.basename(path)}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ))),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: buildListView(context),
    );
  }

  Widget buildListView(BuildContext context) {
    final mp = Provider.of<MusicProvider>(context);
    final musicUnderFolder = Directory(path).listSync();
    musicUnderFolder.sort((m1, m2) {
      if (m1 is File && m2 is File) {
        return p.basename(m1.path).compareTo(p.basename(m2.path));
      }
      if (m1 is Directory && m2 is Directory) {
        return p.basename(m1.path).compareTo(p.basename(m2.path));
      }
      return (m1 is Directory) ? -1 : 1;
    });

    return SmartRefresher(
      enablePullDown: true,
      header: MaterialClassicHeader(),
      controller: _refreshController,
      onRefresh: () async {
        await mp.updateAllSongs();
        _refreshController.refreshCompleted();
      },
      child: ListView(
        children: musicUnderFolder.map((e) => _buildEntry(context, e)).toList(),
      ),
    );
  }

  Widget _buildEntry(BuildContext context, FileSystemEntity e) {
    final mp = Provider.of<MusicProvider>(context);
    if (e is File) {
      return ListTile(
        leading: Icon(Icons.music_note),
        title: Text(
          p.basename(e.path),
        ),
        onTap: () {
          playSong(context, mp.musicPathMap[e.path]);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PlayPage();
          }));
        },
      );
    }

    final folder = e as Directory;
    return ListTile(
      leading: Icon(Icons.folder_open),
      title: Text(p.basename(folder.path)),
      onTap: () {
        setState(() {
          path = (e as Directory).path;
        });
      },
    );
  }
}
