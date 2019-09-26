import 'package:berrycast/resources/musics_provider.dart';
import 'package:flutter/material.dart';

import 'music_album_gallery_page.dart';
import 'music_all_music_page.dart';
import 'music_folder_page.dart';
import 'theme.dart';
import 'utils.dart';

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  bool _isLoading;
  bool _isStoragePermitted;

  @override
  void initState() {
    super.initState();
    if (musicProvider.inited) {
      _isLoading = false;
      _isStoragePermitted = true;
      return;
    }

    _isLoading = true;
    _isStoragePermitted = false;
    _prepare();
  }

  _prepare() async {
    _isStoragePermitted = await ensureStoragePermission();
    if (!_isStoragePermitted) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    await musicProvider.init();

    if (mounted) {
      setState(() {
        _isLoading = false;
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
                      AllMusicPage(),
                      AlbumGalleryPage(),
                      MusicFolderPage(),
                    ]),
                  )),
    );
  }
}
