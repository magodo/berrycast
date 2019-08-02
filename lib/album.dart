import 'package:flutter/material.dart';

import 'songs.dart';

class DemoAlbum {
  final String title;
  final String albumArtUrl;
  final String description;
  final String artist;
  final List<DemoSong> songs;

  DemoAlbum({
    this.title,
    this.albumArtUrl,
    this.description,
    this.artist,
    this.songs,
  });
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
