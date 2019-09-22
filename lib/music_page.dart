import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'model/music.dart';
import 'music_album_gallery_page.dart';
import 'music_all_music_page.dart';
import 'music_folder_page.dart';
import 'theme.dart';
import 'utils.dart';

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  bool _isLoading;
  bool _isStoragePermitted;
  List<Music> _musics = [];
  var _musicAlbumMap = Map<String, List<Music>>();
  var _musicPathMap = Map<String, Music>();
  String _musicCommonAncientDir;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _isStoragePermitted = false;
    _prepare();
  }

  String _getCommonAncientDir(String dir1, dir2) {
    if (dir1.contains(dir2)) return dir2;
    if (dir2.contains(dir1)) return dir1;
    return _getCommonAncientDir(p.dirname(dir1), p.dirname(dir2));
  }

  _prepare() async {
    await Future.delayed(Duration(milliseconds: 200));
    await _updateAllSongs();
    await Future.delayed(Duration(milliseconds: 200));

    for (var music in _musics) {
      final musicFolder = p.dirname(music.audioUrl);
      if (_musicCommonAncientDir == null) {
        _musicCommonAncientDir = musicFolder;
      } else {
        _musicCommonAncientDir =
            _getCommonAncientDir(_musicCommonAncientDir, musicFolder);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _updateAllSongs() async {
    _isStoragePermitted = await ensureStoragePermission();
    if (_isStoragePermitted) {
      var songs = await MusicFinder.allSongs();
      _musics.clear();
      songs.forEach((Song song) {
        final music = Music.fromSong(song);

        _musics.add(music);

        if (_musicAlbumMap[music.albumTitle] == null) {
          _musicAlbumMap[music.albumTitle] = <Music>[music];
        } else {
          _musicAlbumMap[music.albumTitle].add(music);
        }

        _musicPathMap[music.audioUrl] = music;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? CircularProgressIndicator()
          : !_isStoragePermitted
              ?
              // TODO: add retry button
              Center(
                  child: Text("External storage permission needed!"),
                )
              : DefaultTabController(
                  initialIndex: 0,
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      elevation: 1,
                      backgroundColor: Colors.white,
                      title: TabBar(
                        labelColor: accentColor,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(icon: Icon(Icons.music_note)),
                          Tab(icon: Icon(Icons.album)),
                          Tab(icon: Icon(Icons.folder)),
                        ],
                      ),
                    ),
                    body: TabBarView(children: [
                      AllMusicPage(musics: _musics),
                      AlbumGalleryPage(musicAlbumMap: _musicAlbumMap),
                      MusicFolderPage(
                          path: _musicCommonAncientDir,
                          musicPathMap: _musicPathMap),
                    ]),
                  )),
    );
  }
}
