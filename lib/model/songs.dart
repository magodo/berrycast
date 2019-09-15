import 'package:cached_network_image/cached_network_image.dart';

abstract class Song {
  String get audioUrl;
  Duration get audioDuration;
  String get songTitle;
  CachedNetworkImage get albumArt;
  String get artist;
  String get albumTitle;
  bool get isLocal;
}

