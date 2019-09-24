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
  final int trackId;

  Music.fromSong(flut.Song song)
      : audioUrl = song.uri,
        audioDuration = Duration(milliseconds: song.duration),
        songTitle = song.title,
        albumArt = song.albumArt == null
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                    height: 60,
                    width: 60,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: AssetImage('images/logo.png'),
                        ),
                      ),
                    )))
            : SizedBox(
                height: 60,
                width: 60,
                child: Image.file(File(song.albumArt), fit: BoxFit.cover),
              ),
        artist = song.artist,
        albumTitle = song.album,
        trackId = song.trackId;

  String toString() {
    return '''
audioUrl: $audioUrl,
audioDuration: ${audioDuration.inSeconds},
songTitle: $songTitle,
artist: $artist,
album: $albumTitle,
trackId: $trackId
''';
  }
}
