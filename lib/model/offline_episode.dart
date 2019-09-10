import 'package:flutter/material.dart';

class OfflineEpisode {
  final String songUrl;
  final String title;
  final String path;
  final String podcastUrl;
  final double progress;

  OfflineEpisode({
    @required this.songUrl,
    @required this.title,
    @required this.path,
    @required this.podcastUrl,
    @required this.progress,
  });

  factory OfflineEpisode.fromMap(Map<String, dynamic> json) => new OfflineEpisode(
    songUrl: json["song"],
    title: json['title'],
    path: json['path'],
    podcastUrl: json['podcast_url'],
    progress: json["progress"],
  );

  Map<String, dynamic> toMap() => {
    "song": songUrl,
    "title": title,
    "path": path,
    "podcast_url": podcastUrl,
    "progress": progress,
  };
}
