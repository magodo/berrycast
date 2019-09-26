import 'package:berrycast/resources/musics_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'music_album_page.dart';
import 'theme.dart';

class AlbumGalleryPage extends StatefulWidget {
  @override
  _AlbumGalleryPageState createState() => _AlbumGalleryPageState();
}

class _AlbumGalleryPageState extends State<AlbumGalleryPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MusicProvider>(context);
    return SmartRefresher(
      enablePullDown: true,
      header: MaterialClassicHeader(),
      controller: _refreshController,
      onRefresh: () async {
        await mp.updateAllSongs();
        _refreshController.refreshCompleted();
      },
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(4.0),
        childAspectRatio: 1.0,
        children: _buildAlbumThumb(context),
      ),
    );
  }

  List<Widget> _buildAlbumThumb(BuildContext context) {
    final mp = Provider.of<MusicProvider>(context);
    final albumTitles = mp.musicAlbumMap.keys.toList();
    albumTitles.sort();
    return List.generate(albumTitles.length, (idx) {
      var albumMusics = mp.musicAlbumMap[albumTitles[idx]];
      var firstMusic = albumMusics[0];
      return RawMaterialButton(
        shape: CircleBorder(),
        splashColor: lightAccentColor,
        highlightColor: lightAccentColor.withOpacity(0.5),
        elevation: 10.0,
        highlightElevation: 5.0,
        onPressed: () {},
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(firstMusic.albumTitle),
            subtitle: Text(firstMusic.artist),
          ),
          child: InkResponse(
            enableFeedback: true,
            child: firstMusic.albumArt,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AlbumPage(
                      albumMusics: albumMusics,
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
