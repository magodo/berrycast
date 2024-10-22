import 'package:flutter/material.dart';

abstract class Song {
  String get localUri;
  String get originUri;
  Duration get audioDuration;
  String get songTitle;
  Widget get albumArt;
  String get artist;
  String get albumTitle;
  int get trackId;
}
