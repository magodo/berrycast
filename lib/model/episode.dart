import 'package:cached_network_image/cached_network_image.dart';
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
  Duration lastPlayPosition;
  CachedNetworkImage get albumArt => podcast.image;

  String get artist => podcast.author;
  String get albumTitle => podcast.title;

  Episode({
    @required this.audioUrl,
    @required this.audioDuration,
    @required this.songTitle,
    @required this.podcast,
    @required this.pubDate,
    @required this.summary,
    @required this.size,
  });
}
