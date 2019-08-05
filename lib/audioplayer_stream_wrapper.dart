import 'dart:async';
import 'package:async/async.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:rxdart/rxdart.dart';

class AudioPosition extends Duration {
  AudioPosition(Duration position)
      : super(milliseconds: position.inMilliseconds);
}

class AudioDuration extends Duration {
  AudioDuration(Duration dur) : super(milliseconds: dur.inMilliseconds);
}

class SeekPosition extends Duration {
  bool isEnd;
  SeekPosition(Duration dur, {this.isEnd = false}) : super(milliseconds: dur.inMilliseconds);
}

class MyAudioPlayer extends AudioPlayer {
  final StreamController<AudioPosition> _positionController =
      StreamController.broadcast();
  final _seekPositionController = StreamController<SeekPosition>();

  MyAudioPlayer() : super();

  @override
  Stream<AudioPosition> get onAudioPositionChanged => StreamGroup.merge([
        _positionController.stream,
        super.onAudioPositionChanged.map((position) => AudioPosition(position))
      ]);
  void setPosition(AudioPosition pos) {
    _positionController.sink.add(pos);
  }

  Stream<SeekPosition> get onSeekPositionChanged {
    Observable<SeekPosition> seekPositionObservable = Observable.combineLatest2(
        onAudioPositionChanged.map((pos) => SeekPosition(pos)),
        Observable(_seekPositionController.stream).startWith(null),
        (SeekPosition audiopos,SeekPosition seekpos) {
          //print("audio: $audiopos, seek: $seekpos");
          if (seekpos == null) {
            return audiopos;
          }
          if (!seekpos.isEnd) {
            return seekpos;
          }
          // return end seek position, until audio pos is near enough against seek position
          final drift = seekpos.inSeconds - audiopos.inSeconds;
          if (drift.abs() <= 1)  {
            return audiopos;
          }
          return seekpos;
        });
    return seekPositionObservable;
  }

  void setSeekPosition(SeekPosition pos) =>
      _seekPositionController.sink.add(pos);

  @override
  Future<void> dispose() async {
    if (!_positionController.isClosed) {
      await _positionController.close();
    }
    if (!_seekPositionController.isClosed) {
      await _seekPositionController.close();
    }
    await super.dispose();
  }
}
