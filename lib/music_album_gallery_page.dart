import 'package:flutter/material.dart';

import 'model/music.dart';
import 'music_album_page.dart';
import 'theme.dart';

class AlbumGalleryPage extends StatefulWidget {
  final Map<String, List<Music>> musicAlbumMap;

  const AlbumGalleryPage({Key key, this.musicAlbumMap}) : super(key: key);
  @override
  _AlbumGalleryPageState createState() => _AlbumGalleryPageState();
}

class _AlbumGalleryPageState extends State<AlbumGalleryPage> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      padding: const EdgeInsets.all(4.0),
      childAspectRatio: 1.0,
      children: _buildAlbumThumb(context),
    );
  }

  List<Widget> _buildAlbumThumb(BuildContext context) {
    final albumTitles = widget.musicAlbumMap.keys.toList();
    return List.generate(
      albumTitles.length,
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
            child: widget.musicAlbumMap[albumTitles[idx]][0].albumArt,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AlbumPage(
                    albumMusics: widget.musicAlbumMap[albumTitles[idx]]);
              }));
            },
          ),
        ),
      ),
    );
  }
}
