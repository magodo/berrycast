import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:webfeed/webfeed.dart';

import '../songs.dart';

class Podcast {
  final int id;
  final String feedUrl;
  final String imageBase64;
  final String _feedContent;
  final RssFeed _rssFeed;
  List<Episode> _episodes;
  List<Episode> get episodes => _episodes;
  bool isSubscribed;

  Podcast({
    this.id,
    this.feedUrl,
    this.imageBase64,
    feedContent,
    this.isSubscribed,
  })  : _feedContent = feedContent,
        _rssFeed = RssFeed.parse(feedContent) {
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
        id: json["id"],
        feedUrl: json["feed_url"],
        imageBase64: json['image_base64'],
        feedContent: json["feed_content"],
        isSubscribed: true,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "feed_url": feedUrl,
        "image_base64": imageBase64,
        "feed_content": _feedContent,
      };

  String get author => _rssFeed.itunes?.author;
  String get title => _rssFeed.itunes?.title ?? _rssFeed.title;
  String get description => _rssFeed.description;
  CachedNetworkImage get image => CachedNetworkImage(
        imageUrl: _rssFeed.itunes.image.href,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, err) => Image.memory(base64.decode(imageBase64), fit: BoxFit.cover),
    fit: BoxFit.cover,
      );

  static Future<Podcast> newPodcastByUrl(String url) async {
    var resp = await http.get(url);
    var feedContent = utf8.decode(resp.bodyBytes);
    var feed = RssFeed.parse(feedContent);
    var imageResp = await http.get(feed.itunes.image.href);
    var imageBase64 = base64.encode(imageResp.bodyBytes);
    return Podcast(
        feedUrl: url, imageBase64: imageBase64, feedContent: feedContent, isSubscribed: false);
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
