import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OfflineEpisode {
  final String songUrl;
  final String title;
  final String path;
  final String imageUrl;
  final double progress;

  CachedNetworkImage get image => CachedNetworkImage(
    imageUrl: imageUrl,
    placeholder: (context, url) => CircularProgressIndicator(),
    fit: BoxFit.cover,
  );

  OfflineEpisode({
    @required this.songUrl,
    @required this.title,
    @required this.path,
    @required this.imageUrl,
    @required this.progress,
  });

  factory OfflineEpisode.fromMap(Map<String, dynamic> json) => new OfflineEpisode(
    songUrl: json["song"],
    title: json['title'],
    path: json['path'],
    imageUrl: json['image_url'],
    progress: json["progress"],
  );

  Map<String, dynamic> toMap() => {
    "song": songUrl,
    "title": title,
    "path": path,
    "image_url": imageUrl,
    "progress": progress,
  };
}
