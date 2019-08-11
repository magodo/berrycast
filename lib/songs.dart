import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webfeed/domain/rss_feed.dart';

abstract class Song {
  String get audioUrl;
  Duration get audioDuration;
  String get songTitle;
  CachedNetworkImage get albumArt;
  String get artist;
  String get albumTitle;
}

class Episode implements Song {
  final String audioUrl;
  final Duration audioDuration;
  final String songTitle;
  final DateTime pubDate;

  final String _artist;
  final AlbumInfo _albumInfo;
  CachedNetworkImage get albumArt => _albumInfo.coverArt;
  String get artist => _artist ?? _albumInfo.artist;
  String get albumTitle => _albumInfo.title;

  Episode({
    @required this.audioUrl,
    @required this.audioDuration,
    @required this.songTitle,
    @required albumInfo,
    @required this.pubDate,
    String artist,
  })  : _albumInfo = albumInfo,
        _artist = artist;

  String toString() {
    return "audioUrl: $audioUrl, audioDuration: $audioDuration, songTitle: $songTitle, artist: $artist, pubDate: $pubDate, albumTitle: $albumTitle";
  }
}

// TODO
//class LocalSong implements Song {
//}

class AlbumInfo {
  final String title;
  final String artist;
  CachedNetworkImage coverArt;
  final String description;

  AlbumInfo({this.title, this.artist, String coverArtUrl, this.description}) {
   coverArt = CachedNetworkImage(
    imageUrl: coverArtUrl,
     placeholder: (context, url) => new CircularProgressIndicator(),
     errorWidget: (context, url, error) => new Icon(Icons.error),
    fit: BoxFit.cover,
    );
  }
}

abstract class Album {
  CachedNetworkImage get albumArt;
  String get artist;
  String get albumTitle;
  List<Song> get songs;
}

class PodcastAlbum implements Album {
  AlbumInfo info;
  List<Episode> _songs;
  List<Episode> get songs => _songs;

  CachedNetworkImage get albumArt => info.coverArt;
  String get artist => info.artist;
  String get albumTitle => info.title;

  PodcastAlbum(String rssXml) {
    var feed = RssFeed.parse(rssXml);
    info = AlbumInfo(
      title: feed.title,
      artist: feed.itunes?.author ?? "unknown artist",
      description: feed.description,
      coverArtUrl: feed.itunes.image.href,
    );
    _songs = [
      for (var item in feed.items)
        Episode(
          audioUrl: item.enclosure.url,
          audioDuration: item.itunes.duration,
          songTitle: item.title,
          albumInfo: info,
          artist: item?.itunes?.author,
          pubDate: DateFormat("EEE, dd MMM yyyy hh:mm").parse(item.pubDate),
        )
    ];
    _songs.sort((ep1, ep2) => ep2.pubDate.difference(ep1.pubDate).inMilliseconds);
  }

  String toString() {
    var output = """
    albumTitle: $albumTitle
    artist: $artist
    songs:
    """;
    for (var song in songs)  {
      output += """
      $song
      """;
    }
    return output;
  }
}

class PodcastMap with ChangeNotifier {
  final Map<String, PodcastAlbum> _podcasts;

  PodcastMap({podcasts}) : _podcasts = podcasts ?? {};

  Map<String, PodcastAlbum> get podcasts => _podcasts;

  void add(PodcastAlbum podcast) {
    if (_podcasts[podcast.info.title] == null) {
      _podcasts[podcast.info.title] = podcast;
      notifyListeners();
    }
  }

  void remove(PodcastAlbum podcast) {
    if (_podcasts[podcast.info.title] != null) {
      _podcasts.remove(podcast.info.title);
      notifyListeners();
    }
  }
}

PodcastMap globalPodcastMap = PodcastMap();

class PodcastStorage {
  final AlbumInfo albumInfo;
  final String rssFeedUrl;

  PodcastStorage({
    @required this.albumInfo,
    @required this.rssFeedUrl,
  });
}

Map<String, PodcastStorage> podcastStorage = {
  "ggtalk": PodcastStorage(
      albumInfo: AlbumInfo(
          title: "ggtalk",
          artist: "梁杰",
          coverArtUrl: "https://talkcdn.swift.gg/static/logo.jpg",
          description: ""),
      rssFeedUrl: "https://talk.swift.gg/static/rss.xml"),
  "内核恐慌": PodcastStorage(
      albumInfo: AlbumInfo(
          title: "内核恐慌",
          artist: "吴涛, Rio",
          coverArtUrl:
              "https://kernelpanic.fm/assets/icon-kernelpanic-1800.png",
          description: ""),
      rssFeedUrl: "https://kernelpanic.fm/feed"),
  "Go Time": PodcastStorage(
    albumInfo: AlbumInfo(
        title: "Go Time",
        artist: "Changelog Media",
        coverArtUrl: "https://cdn.changelog.com/uploads/covers/go-time-original.png?v=63725770357",
        description: ""),
    rssFeedUrl: "https://changelog.com/gotime/feed",
  ),
};

Future<PodcastAlbum> getPodcast(String title) async {
  if (globalPodcastMap?.podcasts[title] != null)
    return globalPodcastMap.podcasts[title];
  final response = await http.get(podcastStorage[title].rssFeedUrl);
  var podcast = PodcastAlbum(utf8.decode(response.bodyBytes));
  globalPodcastMap.add(podcast);
  return podcast;
}
