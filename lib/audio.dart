import 'package:flutter/material.dart';

import 'audioplayer_stream_wrapper.dart';
import 'songs.dart';

class AudioSchedule with ChangeNotifier {
  final MyAudioPlayer player;
  DemoPlaylist _playlist;
  int _playIdx;

  AudioSchedule()
      : player = MyAudioPlayer(),
        _playlist = demoPlaylist,
        _playIdx = 0;

  DemoPlaylist get playlist => _playlist;
  set playlist(DemoPlaylist playlist) {
    _playlist = playlist;
    _playIdx = 0;
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

  void _changeSong() async {
    player.stop();
    player.setPosition(Duration());
    player.play(_playlist.songs[_playIdx].audioUrl);
    notifyListeners();
  }

  void forward10() async {
    var pos = await player.getCurrentPosition();
    player.seek(Duration(milliseconds: pos + 10 * 1000));
    notifyListeners();
  }

  void replay10() async {
    var pos = await player.getCurrentPosition();
    player.seek(Duration(milliseconds: pos - 10 * 1000));
    notifyListeners();
  }

  void seek(double percent) {
    player.seek(song.duration * percent);
    player.play(song.audioUrl);
    notifyListeners();
  }

  void play() {
    player.play(song.audioUrl);
  }

  void resume() {
    player.resume();
  }

  void pause() {
    player.pause();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
