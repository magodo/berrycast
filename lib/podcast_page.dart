import 'package:flutter/material.dart';

import 'album_page.dart';
import 'songs.dart';
import 'theme.dart';

class PodcastPage extends StatelessWidget {
  _openAlbumPage(BuildContext context, PodcastAlbum album) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AlbumPage(album: album);
    }));
  }

  _openSnackBar(BuildContext context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("Loading..."),
      ),
    );
  }

  List<Widget> _buildAlbumThumb(BuildContext context) {
    Map<String, AlbumInfo> albumMaps = {
      ...podcastStorage?.map((k, v) => MapEntry(k, v.albumInfo)),
      ...globalPodcastMap?.podcasts?.map((k, v) => MapEntry(k, v.info)),
    };
    List<AlbumInfo> albums = albumMaps.values.toList();

    return List.generate(
      albums.length,
      (idx) => RawMaterialButton(
        shape: CircleBorder(),
        splashColor: lightAccentColor,
        highlightColor: lightAccentColor.withOpacity(0.5),
        elevation: 10.0,
        highlightElevation: 5.0,
        onPressed: () {},
        child: GridTile(
          child: InkResponse(
            enableFeedback: true,
            child: FutureBuilder<PodcastAlbum>(
              future: getPodcast(albums[idx].title),
              builder:
                  (BuildContext context, AsyncSnapshot<PodcastAlbum> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  case ConnectionState.done:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                }
                return snapshot.data.info.coverArt;
              },
            ),
            //albumList.albums[idx].albumArt,
            onTap: () {
              if (globalPodcastMap?.podcasts[albums[idx].title] == null) {
                _openSnackBar(context);
                return;
              }
              _openAlbumPage(
                  context, globalPodcastMap.podcasts[albums[idx].title]);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          padding: const EdgeInsets.all(4.0),
          childAspectRatio: 1.0,
          children: _buildAlbumThumb(context)),
    );
  }
}
