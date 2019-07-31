class AudioPosition extends Duration {
  AudioPosition(Duration position):super(milliseconds: position.inMilliseconds);
}
class AudioDuration extends Duration {
  AudioDuration(Duration dur):super(milliseconds: dur.inMilliseconds);
}
