import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'model/music.dart';
import 'play_page.dart';
import 'radial_seekbar.dart';
import 'theme.dart';
import 'utils.dart';

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  bool _isLoading;
  bool _isStoragePermitted;
  List<Music> _musics = [];

  @override
  void initState() {
    print("init...");
    super.initState();
    _isLoading = true;
    _isStoragePermitted = false;
    _prepare();
  }

  _prepare() async {
    await Future.delayed(Duration(milliseconds: 200));
    await _updateAllSongs();
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {
      _isLoading = false;
    });
  }

  _updateAllSongs() async {
    _isStoragePermitted = await ensureStoragePermission();
    if (_isStoragePermitted) {
      var songs = await MusicFinder.allSongs();
      _musics.clear();
      songs.forEach((song) {
        _musics.add(Music.fromSong(song));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? CircularProgressIndicator()
          : !_isStoragePermitted
              ?
              // TODO: add retry button
              Center(
                  child: Text("External storage permission needed!"),
                )
              : DefaultTabController(
                  initialIndex: 0,
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      elevation: 1,
                      backgroundColor: Colors.white,
                      title: TabBar(
                        labelColor: accentColor,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(icon: Icon(Icons.music_note)),
                          Tab(icon: Icon(Icons.album)),
                          Tab(icon: Icon(Icons.folder)),
                        ],
                      ),
                    ),
                    body: TabBarView(children: [
                      MusicView(musics: _musics),
                      Container(),
                      Container(),
                    ]),
                  )),
    );
  }
}

class MusicView extends StatefulWidget {
  final List<Music> musics;

  const MusicView({Key key, this.musics}) : super(key: key);

  @override
  _MusicViewState createState() => _MusicViewState();
}

class _MusicViewState extends State<MusicView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.musics
          .map((e) => Card(
                child: ListTile(
                  leading: ClipOval(
                    clipper: CircleClipper(),
                    child: e.albumArt,
                  ),
                  onTap: () => _playMusic(context, e),
                  title: Text(
                    e.songTitle,
                  ),
                  subtitle: Text(e.artist + " - " + e.albumTitle),
                  trailing:
                      IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
                ),
              ))
          .toList(),
    );
  }
}

void _playMusic(BuildContext context, Music music) {
  final schedule = Provider.of<AudioSchedule>(context);
  schedule.pushSong(music);
  schedule.playNthSong(0);
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return PlayPage();
  }));
}
