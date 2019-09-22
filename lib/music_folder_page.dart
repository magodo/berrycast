import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'model/music.dart';
import 'sliver_appbar_delegate.dart';
import 'utils.dart';

class MusicFolderPage extends StatefulWidget {
  final Map<String, Music> musicPathMap;
  final String path;

  const MusicFolderPage({Key key, this.path, this.musicPathMap})
      : super(key: key);

  @override
  _MusicFolderPageState createState() => _MusicFolderPageState(path);
}

class _MusicFolderPageState extends State<MusicFolderPage> {
  String path;

  _MusicFolderPageState(this.path);

  @override
  Widget build(BuildContext context) {
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
                    path == widget.path
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
      body: ListView(
        children: Directory(path)
            .listSync()
            .map((e) => _buildEntry(context, e))
            .toList(),
      ),
    );
  }

  Widget _buildEntry(BuildContext context, FileSystemEntity e) {
    if (e is File) {
      return ListTile(
        leading: Icon(Icons.music_note),
        title: Text(
          p.basename(e.path),
        ),
        onTap: () => playSong(context, widget.musicPathMap[e.path]),
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
