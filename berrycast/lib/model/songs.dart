import 'package:flutter/material.dart';

abstract class Song {
  String get playUri;
  String get originUri;
  Duration get audioDuration;
  String get songTitle;
  Widget get albumArt;
  String get artist;
  String get albumTitle;
  bool get isLocal;
  int get trackId;
}
