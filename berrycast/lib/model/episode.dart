import 'package:flutter/material.dart';

import 'podcast.dart';
import 'songs.dart';

class Episode implements Song {
  final String originUri;
  final String localUri;
  final Duration audioDuration;
  final String songTitle;
  final Podcast podcast;
  final DateTime pubDate;
  final String summary;
  final int size;
  Duration lastPlayPosition;
  Widget get albumArt => podcast.image;

  String get artist => podcast.author;
  String get albumTitle => podcast.title;
  int get trackId =>
      podcast.episodes.indexWhere((e) => e.originUri == originUri);

  Episode({
    @required this.originUri,
    @required this.localUri,
    @required this.audioDuration,
    @required this.songTitle,
    @required this.podcast,
    @required this.pubDate,
    @required this.summary,
    @required this.size,
  });
}
