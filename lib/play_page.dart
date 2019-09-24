import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'button_controls.dart';
import 'model/episode.dart';
import 'radial_seekbar.dart';
import 'theme.dart';
import 'utils.dart';

class PlayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        endDrawer: buildPlaylist(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: <Widget>[
            Builder(builder: (context) {
              final schedule = Provider.of<AudioSchedule>(context);
              final song = schedule.song;
              if (song is Episode) {
                return IconButton(
                  icon: Icon(Icons.cast),
                  color: Colors.grey,
                  onPressed: () => openPodcastPage(context, song.podcast),
                );
              }
              return Container();
            }),
//            Builder(builder: (context) {
//              final schedule = Provider.of<AudioSchedule>(context);
//              final song = schedule.song;
//              if (song is Episode) {
//                return IconButton(
//                  icon: Icon(Icons.info_outline),
//                  color: Colors.grey,
//                  onPressed: () => buildBottomSheet(context, song),
//                );
//              }
//              return Container();
//            }),
            Builder(builder: (context) {
              return IconButton(
                icon: Icon(Icons.playlist_play),
                color: Colors.grey,
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              );
            }),
          ],
        ),
        body: Column(
          children: <Widget>[
            // seek bar
            Expanded(child: RadialSeekBar()),

            // visualizer
            Container(
              width: double.infinity,
              height: 125.0,
            ),

            // song title, artist name and controls
            ButtonControls(),
          ],
        ),
      ),
    );
  }

  Drawer buildPlaylist(BuildContext context) {
    final schedule = Provider.of<AudioSchedule>(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: DrawerHeader(
              padding: EdgeInsets.all(0),
              child: ListTileTheme(
                style: ListTileStyle.drawer,
                child: Center(
                  child: ListTile(
                    title: Text(
                      "PLAYLIST",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 15,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: schedule.playlist.length == 0
                          ? null
                          : () async {
                              final toDelete =
                                  await showDeleteConfirmDialog(context);
                              if (toDelete) {
                                Provider.of<AudioSchedule>(context).playlist =
                                    [];
                              }
                            },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 10,
            child: ReorderableListView(
              onReorder: (oldIdx, newIdx) {
                Provider.of<AudioSchedule>(context)
                    .reorderPlaylist(oldIdx, newIdx);
              },
              children: _buildPlaylist(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlaylist(context) {
    final schedule = Provider.of<AudioSchedule>(context);
    return schedule.playlist
        .asMap()
        .map((idx, song) => MapEntry(
              idx,
              Dismissible(
                background: Container(
                  alignment: Alignment(-0.8, 0),
                  color: accentColor,
                  child: Icon(Icons.cancel),
                ),
                key: ValueKey(song),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  final playlist = schedule.playlist;
                  playlist.removeAt(idx);
                  schedule.playlist = playlist;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(flex: 1, child: Text("$idx")),
                      Flexible(
                        flex: 10,
                        child: ListTile(
                          selected: schedule.isSongIdxActive(idx),
                          leading: song.albumArt,
                          trailing: Icon(Icons.reorder),
                          title: Text(song.songTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              )),
                          onTap: () => schedule.playNthSong(idx),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ))
        .values
        .toList();
  }
}
