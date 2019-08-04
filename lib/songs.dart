import 'package:flutter/material.dart';

class DemoSong {
  final String audioUrl;
  final Image albumArt;
  final String songTitle;
  final String artist;
  final Duration duration;

  DemoSong({
    @required this.audioUrl,
    @required String albumArtUrl,
    @required this.songTitle,
    @required this.artist,
    @required this.duration,
  }) : albumArt = Image.network(albumArtUrl, fit: BoxFit.cover);
}

class DemoAlbum {
  final String title;
  final Image albumArt;
  final String description;
  final String artist;
  final List<DemoSong> songs;

  DemoAlbum({
    this.title,
    String albumArtUrl,
    this.description,
    this.artist,
    this.songs,
  }) : albumArt = Image.network(albumArtUrl, fit: BoxFit.cover);
}

class DemoAlbumList with ChangeNotifier {
  final List<DemoAlbum> _albums;

  DemoAlbumList({albums}) : _albums = albums;

  List<DemoAlbum> get albums => _albums;

  void add(DemoAlbum album) {
    if (!_albums.contains(album)) {
      _albums.add(album);
      notifyListeners();
    }
  }

  void remove(DemoAlbum album) {
    if (_albums.remove(album)) {
      notifyListeners();
    }
  }
}

final demoAlbumList = DemoAlbumList(
  albums: [
    DemoAlbum(
      title: "ggtalk",
      albumArtUrl: "https://talkcdn.swift.gg/static/logo.jpg",
      artist: "梁杰",
      songs: [
        DemoSong(
          audioUrl: "https://talkcdn.swift.gg/audio/1.mp3",
          albumArtUrl: "https://talkcdn.swift.gg/static/logo.jpg",
          songTitle: "聊聊程序员的升职加薪（上）",
          artist: "梁杰",
          duration: Duration(minutes: 57, seconds: 15),
        ),
        DemoSong(
          audioUrl: "https://talkcdn.swift.gg/audio/2.mp3",
          albumArtUrl: "https://talkcdn.swift.gg/static/logo.jpg",
          songTitle: "我都花时间搭博客了，为什么还要花时间写？",
          artist: "梁杰",
          duration: Duration(minutes: 47, seconds: 33),
        ),
        DemoSong(
          audioUrl: "https://talkcdn.swift.gg/audio/3.mp3",
          albumArtUrl: "https://talkcdn.swift.gg/static/logo.jpg",
          songTitle: "和裕波聊聊如何办一场技术大会（上）",
          artist: "梁杰",
          duration: Duration(hours: 1, minutes: 4, seconds: 14),
        ),
      ],
    ),
    DemoAlbum(
      title: "内核恐慌",
      albumArtUrl: "https://kernelpanic.fm/assets/icon-kernelpanic-1800.png",
      artist: "吴涛,Riog",
      songs: [
        DemoSong(
          audioUrl: "https://kernelpanic.fm/1/audio.mp3",
          albumArtUrl:
              "https://kernelpanic.fm/assets/icon-kernelpanic-1800.png",
          songTitle: "1. 内核恐慌开播！",
          artist: "吴涛,Riog",
          duration: Duration(seconds: 3464),
        ),
      ],
    ),
  ],
);
