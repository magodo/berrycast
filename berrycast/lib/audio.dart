import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'audioplayer_stream_wrapper.dart';
import 'model/episode.dart';
import 'model/songs.dart';
import 'resources/db.dart';

enum LoopMode {
  repeat,
  repeatOne,
  shuffle,
}

final loopModes = <LoopMode>[
  LoopMode.repeat,
  LoopMode.repeatOne,
  LoopMode.shuffle
];

class AudioSchedule with ChangeNotifier {
  final MyAudioPlayer player;
  List<Song> _playlist;
  Song _song;
  LoopMode _loopMode = LoopMode.repeat;

  AudioSchedule()
      : player = MyAudioPlayer(),
        _playlist = <Song>[] {
    // The default RELEASE mode will release audio after it finishes. In which case
    // it we will have platform exception if try to get current seek position via player.
    // (since we want to record play history whenever audio focus is disabled (see code below: [player.focusHandler]))
    player.setReleaseMode(ReleaseMode.STOP);

    // listen on complete event and play next song
    player.onPlayerCompletion.listen((event) {
      nextSong();
    });

    // Remember play history whenever audio focus is disabled.
    // Explicitly use the deprecated [focusHanlder] here because it's more fit then using stream.
    player.focusHandler = (focused) async {
      if (song != null) {
        await _recordPlayHistory();
      }
    };
  }

  LoopMode get loopMode => _loopMode;
  set loopMode(LoopMode mode) {
    _loopMode = mode;
    notifyListeners();
  }

  List<Song> get playlist => _playlist;
  set playlist(List<Song> playlist) {
    _playlist = playlist;
    notifyListeners();
  }

  bool get isEmpty => playlist.length == 0;

  Song get song => _song;

  void pushSong(Song song) {
    playlist.removeWhere((e) => song.originUri == e.originUri);
    playlist.insert(0, song);
    notifyListeners();
    return;
  }

  bool isSongIdxActive(int idx) {
    return playlist[idx].originUri == song.originUri;
  }

  void reorderPlaylist(int oldIdx, int newIdx) {
    // These two lines are workarounds for ReorderableListView problems
    if (newIdx > _playlist.length) newIdx = _playlist.length;
    if (oldIdx < newIdx) newIdx--;
    _playlist.insert(newIdx, _playlist.removeAt(oldIdx));
    notifyListeners();
  }

  void prevSong() {
    final playIdx = playlist.indexWhere((e) => e.originUri == song.originUri);
    if (playIdx == -1 && playlist.length > 0) {
      playNthSong(0);
    }
    playNthSong((playIdx - 1) % _playlist.length);
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

  seekPercentage(double percentage) async {
    await player.seek(song.audioDuration * percentage);
    play();
  }

  playFrom({Duration from}) async {
    from = from ?? await DBProvider.db.getPlayHistory(song.originUri);
    player.play(song.localUri ?? song.originUri,
        respectAudioFocus: true,
        isLocal: song.localUri != null,
        position: from);
  }

  play() async {
    player.play(song.localUri ?? song.originUri,
        respectAudioFocus: true, isLocal: song.localUri != null);
  }

  Future<void> playNthSong(int idx, {Duration from}) async {
    if (song == null) {
      _song = playlist[idx];
      await playFrom(from: from);
      notifyListeners();
      return;
    }

    if (song.originUri == playlist[idx].originUri) {
      // For the same song, if specified from (e.g. because of choose one bookmark),
      // play from there.
      if (from != null) {
        await playFrom(from: from);
        return;
      }

      // Otherwise, just continue playing
      await play();
      return;
    }

    await pause();
    _song = playlist[idx];
    await playFrom(from: from);
    notifyListeners();
  }

  void resume() {
    player.resume();
  }

  Future<void> pause() async {
    if (song != null) {
      await player.pause();
      await _recordPlayHistory();
    }
  }

  Future<void> stop() async {
    if (song != null) {
      await player.stop();
      await _recordPlayHistory();
    }
  }

  Future<void> _recordPlayHistory() async {
    Duration duration;

    // episode should record playhistory, while music should not
    if (song is Episode) {
      duration = Duration(milliseconds: await player.getCurrentPosition());
      DBProvider.db.addPlayHistory(song.originUri, duration);
      print("history recorded for ${song.songTitle} @${duration.toString()}");
    }
  }

  void _nextSongRepeat() {
    final playIdx = playlist.indexWhere((e) => e.originUri == song.originUri);
    playNthSong((playIdx + 1) % _playlist.length);
    return;
  }

  void _nextSongRepeatOne() {
    playFrom(from: Duration());
    return;
  }

  void _nextSongShuffle() {
    var rng = Random();
    final idx = rng.nextInt(_playlist.length);
    playNthSong(idx);
    return;
  }

  void nextSong() async {
    await player.pause();
    if (playlist.length == 0) {
      return;
    }

    switch (_loopMode) {
      case LoopMode.repeatOne:
        _nextSongRepeatOne();
        return;
      case LoopMode.repeat:
        _nextSongRepeat();
        return;
      case LoopMode.shuffle:
        _nextSongShuffle();
        return;
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
