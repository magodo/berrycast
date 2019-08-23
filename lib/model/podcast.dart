import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:webfeed/webfeed.dart';

import '../resources/db.dart';
import '../songs.dart';

class Podcast {
  final String feedUrl;
  final String imageUrl;
  final String feedContent;
  final RssFeed _rssFeed;
  List<Episode> _episodes;
  List<Episode> get episodes => _episodes;
  bool isSubscribed;

  Podcast({
    this.feedUrl,
    this.imageUrl,
    this.feedContent,
    this.isSubscribed,
  }) : _rssFeed = RssFeed.parse(feedContent) {
    _episodes = [
      for (var item in _rssFeed.items)
        Episode(
          audioUrl: item.enclosure.url,
          audioDuration: item.itunes.duration,
          songTitle: item.title,
          pubDate: DateFormat("EEE, dd MMM yyyy hh:mm").parse(item.pubDate),
          podcast: this,
        )
    ];
    _episodes
        .sort((ep1, ep2) => ep2.pubDate.difference(ep1.pubDate).inMilliseconds);
  }

  factory Podcast.fromJson(String str) => Podcast.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Podcast.fromMap(Map<String, dynamic> json) => new Podcast(
        feedUrl: json["feed_url"],
        imageUrl: json['image_url'],
        feedContent: json["feed_content"],
        isSubscribed: true,
      );

  Map<String, dynamic> toMap() => {
        "feed_url": feedUrl,
        "image_url": imageUrl,
        "feed_content": feedContent,
      };

  String get author => _rssFeed.itunes?.author;
  String get title => _rssFeed.itunes?.title ?? _rssFeed.title;
  String get description => _rssFeed.description;
  CachedNetworkImage get image => CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => CircularProgressIndicator(),
        fit: BoxFit.cover,
      );

  static Future<Podcast> newPodcastByUrl(String url, {String imageUrl}) async {
    var resp = await http.get(url);
    var feedContent = utf8.decode(resp.bodyBytes);
    var feed = RssFeed.parse(feedContent);
    var isSubscribed = await DBProvider.db.getPodcast(url) != null;
    return Podcast(
        feedUrl: url,
        imageUrl: imageUrl ?? feed.itunes.image.href,
        feedContent: feedContent,
        isSubscribed: isSubscribed);
  }
}

class Episode implements Song {
  final String audioUrl;
  final Duration audioDuration;
  final String songTitle;
  final Podcast podcast;
  final DateTime pubDate;
  CachedNetworkImage get albumArt => podcast.image;

  String get artist => podcast.author;
  String get albumTitle => podcast.title;

  Episode({
    @required this.audioUrl,
    @required this.audioDuration,
    @required this.songTitle,
    @required this.pubDate,
    @required this.podcast,
  });
}
