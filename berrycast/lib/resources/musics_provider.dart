import 'package:flute_music_player/flute_music_player.dart' as flut;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../model/music.dart';

class MusicProvider with ChangeNotifier {
  bool _inited = false;
  List<Music> _musics = [];
  var _musicAlbumMap = Map<String, List<Music>>();
  var _musicPathMap = Map<String, Music>();
  String _musicCommonAncientDir;

  bool get inited => _inited;
  List<Music> get musics => _musics;
  Map<String, List<Music>> get musicAlbumMap => _musicAlbumMap;
  Map<String, Music> get musicPathMap => _musicPathMap;
  String get musicCommonAncientDir => _musicCommonAncientDir;

  init() async {
    if (_musics.length == 0) {
      await Future.delayed(Duration(milliseconds: 500));
      await updateAllSongs();
      await Future.delayed(Duration(milliseconds: 500));
      _inited = true;
      notifyListeners();
    }
  }

  updateAllSongs() async {
    _musics.clear();
    _musicAlbumMap.clear();
    _musicPathMap.clear();
    _musicCommonAncientDir = null;

    var songs = await flut.MusicFinder.allSongs();

    songs.forEach((flut.Song song) {
      final music = Music.fromSong(song);

      _musics.add(music);

      if (_musicAlbumMap[music.albumTitle] == null) {
        _musicAlbumMap[music.albumTitle] = <Music>[music];
      } else {
        _musicAlbumMap[music.albumTitle].add(music);
      }

      _musicPathMap[music.originUri] = music;

      final musicFolder = p.dirname(music.originUri);
      if (_musicCommonAncientDir == null) {
        _musicCommonAncientDir = musicFolder;
      } else {
        _musicCommonAncientDir =
            _getCommonAncientDir(_musicCommonAncientDir, musicFolder);
      }
    });

    notifyListeners();
  }

  String _getCommonAncientDir(String dir1, dir2) {
    if (dir1.contains(dir2)) return dir2;
    if (dir2.contains(dir1)) return dir1;
    return _getCommonAncientDir(p.dirname(dir1), p.dirname(dir2));
  }
}

final MusicProvider musicProvider = MusicProvider();
