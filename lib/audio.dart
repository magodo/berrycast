import 'package:flutter/material.dart';

import 'audioplayer_stream_wrapper.dart';
import 'songs.dart';

class AudioSchedule with ChangeNotifier {
  final MyAudioPlayer player;
  List<DemoSong> _playlist;
  int _playIdx;
  DemoSong _song;

  AudioSchedule()
      : player = MyAudioPlayer(),
        _playlist = null,
        _playIdx = 0;

  List<DemoSong> get playlist => _playlist;
  set playlist(List<DemoSong> playlist) {
    _playlist = playlist;
    _playIdx = 0;
  }

  bool get isEmpty => _playlist == null;

  DemoSong get song => _song;
  set song (DemoSong song) {
    _song = song;
    notifyListeners();
  }

  bool isSongIdxActive(int idx) {
    return idx == _playIdx;
  }

  void reorderPlaylist(int oldIdx, int newIdx) {
    // These two lines are workarounds for ReorderableListView problems
    if (newIdx > _playlist.length) newIdx = _playlist.length;
    if (oldIdx < newIdx) newIdx--;

    print("oldIdx: $oldIdx, newIdx: $newIdx");
    if (oldIdx < _playIdx && newIdx >= _playIdx) {
      _playIdx--;
    } else if (oldIdx > _playIdx && newIdx <= _playIdx) {
      _playIdx++;
    } else if (oldIdx == _playIdx) {
      _playIdx = newIdx;
    }
    _playlist.insert(newIdx, _playlist.removeAt(oldIdx));
    notifyListeners();
  }

  void nextSong() {
    _playIdx = (_playIdx + 1) % _playlist.length;
    _changeSong();
  }

  void prevSong() {
    _playIdx = (_playIdx - 1) % _playlist.length;
    _changeSong();
  }

  void _changeSong() async {
    playNthSong(_playIdx);
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
  }

  void play() {
    player.play(song.audioUrl);
  }

  void _playFromHead() {
    player.setPosition(AudioPosition(Duration()));
    player.setSeekPosition(null);
    player.play(song.audioUrl);
  }

  void playNthSong(int idx) {
    _playIdx = idx;
    final targetSong = _playlist[idx];
    if (targetSong == song) {
      play();
    }

    song = targetSong;
    _playFromHead();
    notifyListeners();
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
