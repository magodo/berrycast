import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart' as flut;
import 'package:flutter/material.dart';

import 'songs.dart';

class Music implements Song {
  final String audioUrl;
  final Duration audioDuration;
  final String songTitle;
  final Widget albumArt;
  final String artist;
  final String albumTitle;
  final bool isLocal = true;

  Music.fromSong(flut.Song song)
      : audioUrl = song.uri,
        audioDuration = Duration(milliseconds: song.duration),
        songTitle = song.title,
        albumArt = Image.file(File(song.albumArt)),
        artist = song.artist,
        albumTitle = song.album;

  String toString() {
    return '''
audioUrl: $audioUrl,
audioDuration: ${audioDuration.inSeconds},
songTitle: $songTitle,
artist: $artist,
album: $albumTitle
''';
  }
}
