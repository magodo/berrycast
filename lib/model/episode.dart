import 'package:flutter/material.dart';

import 'podcast.dart';
import 'songs.dart';

class Episode implements Song {
  final String audioUrl;
  final Duration audioDuration;
  final String songTitle;
  final Podcast podcast;
  final DateTime pubDate;
  final String summary;
  final int size;
  final bool isLocal;
  Duration lastPlayPosition;
  Widget get albumArt => podcast.image;

  String get artist => podcast.author;
  String get albumTitle => podcast.title;
  int get trackId => podcast.episodes.indexWhere((e) => e.audioUrl == audioUrl);

  Episode({
    @required this.audioUrl,
    @required this.audioDuration,
    @required this.songTitle,
    @required this.podcast,
    @required this.pubDate,
    @required this.summary,
    @required this.size,
    @required this.isLocal,
  });
}
