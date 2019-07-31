import 'package:flutter/material.dart';

class DemoSong {
  final String audioUrl;
  final String albumArtUrl;
  final String songTitle;
  final String artist;
  final Duration duration;

  DemoSong({
    @required this.audioUrl,
    @required this.albumArtUrl,
    @required this.songTitle,
    @required this.artist,
    @required this.duration,
  });
}

class DemoPlaylist {
  final List<DemoSong> songs;
  DemoPlaylist({@required this.songs});
}

final demoPlaylist = DemoPlaylist(songs: [
//  DemoSong(
//    audioUrl: "https://cdn.changelog.com/uploads/gotime/90/go-time-90.mp3",
//    albumArtUrl:
//        "https://cdn.changelog.com/uploads/covers/go-time-original.png",
//    songTitle: "Go tooling",
//    artist: "with Mat, Jaana & Johnny",
//    duration: Duration(milliseconds: 95970193),
//  ),
  DemoSong(
    audioUrl: "https://talkcdn.swift.gg/audio/1.mp3",
    albumArtUrl: "https://talkcdn.swift.gg/static/logo.jpg",
    songTitle: "聊聊程序员的升职加薪（上）",
    artist: "梁杰",
    duration: Duration(minutes: 57, seconds: 15),
  ),
  DemoSong(
    audioUrl: "https://kernelpanic.fm/1/audio.mp3",
    albumArtUrl: "https://kernelpanic.fm/assets/icon-kernelpanic-1800.png",
    songTitle: "1. 内核恐慌开播！",
    artist: "吴涛,Riog",
    duration: Duration(seconds: 3464),
  ),
]);
