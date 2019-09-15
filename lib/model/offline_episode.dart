import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class OfflineEpisode {
  final String songUrl;
  final String title;
  final String podcastUrl;
  final String imageUrl;
  String taskID;
  DownloadTask taskInfo;

  CachedNetworkImage get image => CachedNetworkImage(
    imageUrl: imageUrl,
    placeholder: (context, url) => CircularProgressIndicator(),
    fit: BoxFit.cover,
  );

  OfflineEpisode({
    @required this.songUrl,
    @required this.title,
    @required this.podcastUrl,
    @required this.imageUrl,
    @required this.taskID,
  });

  factory OfflineEpisode.fromMap(Map<String, dynamic> json) => new OfflineEpisode(
    songUrl: json["song"],
    title: json['title'],
    podcastUrl: json['podcast_url'],
    imageUrl: json["image_url"],
    taskID: json["task_id"],
  );

  Map<String, dynamic> toMap() => {
    "song": songUrl,
    "title": title,
    "podcast_url": podcastUrl,
    "image_url": imageUrl,
    "task_id": taskID,
  };
}
