import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'songs.dart';

class AudioSchedule with ChangeNotifier {
  final AudioPlayer player;
  DemoPlaylist _playlist;
  int _playIdx;
  Duration _progress;

  AudioSchedule()
      : player = AudioPlayer(),
        _playlist = demoPlaylist,
        _playIdx = 0,
        _progress = Duration();

  DemoPlaylist get playlist => _playlist;
  set playlist(DemoPlaylist playlist) {
    _playlist = playlist;
    notifyListeners();
  }

  Duration get progress => _progress;
  set progress(Duration dur) {
    _progress = dur;
  }

  DemoSong get song => _playlist.songs[_playIdx];
  set setSong(int idx) {
    _playIdx = idx;
    notifyListeners();
  }

  void nextSong() {
    _playIdx = (_playIdx + 1) % _playlist.songs.length;
    _changeSong();
  }

  void prevSong() {
    _playIdx = (_playIdx - 1) % _playlist.songs.length;
    _changeSong();
  }

  void _changeSong() {
    player.stop();
    player.play(_playlist.songs[_playIdx].audioUrl);
    notifyListeners();
  }

  void forward10() {
    player.seek(_progress + Duration(seconds: 10));
    notifyListeners();
  }

  void replay10() {
    player.seek(_progress - Duration(seconds: 10));
    notifyListeners();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
