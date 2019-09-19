import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'buttom_controls.dart';
import 'model/episode.dart';
import 'radial_seekbar.dart';
import 'utils.dart';

class PlayPage extends StatelessWidget {
  List<Widget> _buildPlaylist(context) {
    final schedule = Provider.of<AudioSchedule>(context);
    return schedule.playlist
        .asMap()
        .map((idx, song) => MapEntry(
            idx,
            Padding(
              key: ValueKey(song),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            )))
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        endDrawer: Drawer(
          child: ReorderableListView(
            onReorder: (oldIdx, newIdx) {
              Provider.of<AudioSchedule>(context)
                  .reorderPlaylist(oldIdx, newIdx);
            },
            children: _buildPlaylist(context),
          ),
        ),
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
                  onPressed: () => openExistAlbumPage(context, song.podcast),
                );
              }
              return Container();
            }),
            Builder(builder: (context) {
              final schedule = Provider.of<AudioSchedule>(context);
              final song = schedule.song;
              if (song is Episode) {
                return IconButton(
                  icon: Icon(Icons.info_outline),
                  color: Colors.grey,
                  onPressed: () => buildBottomSheet(context, song),
                );
              }
              return Container();
            }),
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
}
