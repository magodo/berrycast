import 'dart:async';
import 'package:async/async.dart';

import 'package:audioplayers/audioplayers.dart';

class AudioPosition extends Duration {
  AudioPosition(Duration position)
      : super(milliseconds: position.inMilliseconds);
}

class AudioDuration extends Duration {
  AudioDuration(Duration dur) : super(milliseconds: dur.inMilliseconds);
}

class MyAudioPlayer extends AudioPlayer {
  final _positionController = StreamController<AudioPosition>();
  MyAudioPlayer() : super();

  @override
  Stream<Duration> get onAudioPositionChanged => StreamGroup.merge([
        _positionController.stream,
        super.onAudioPositionChanged.map((position) => AudioPosition(position))
      ]);
  void setPosition(Duration dur) {
    _positionController.sink.add(AudioPosition(dur));
  }

  @override
  Future<void> dispose() async {
    if (!_positionController.isClosed) {
      await _positionController.close();
    }
    await super.dispose();
  }
}
