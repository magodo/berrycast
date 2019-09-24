import 'package:flutter/material.dart';

import 'bottom_bar.dart';
import 'drawer_header.dart';
import 'music_page.dart';
import 'offline_episode_page.dart';
import 'podcast_gallery_page.dart';
import 'search_page.dart';
import 'theme.dart';
import 'utils.dart';

class Home extends StatefulWidget {
  const Home({
    Key key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = true;

    _prepare();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Berrycast",
              style: TextStyle(color: Colors.white),
            ),
            leading: Builder(builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu),
                color: Colors.white,
                onPressed: Scaffold.of(context).openDrawer,
              );
            }),
            bottom: TabBar(tabs: [
              Tab(icon: Icon(Icons.cast)),
              Tab(icon: Icon(Icons.library_music)),
              Tab(icon: Icon(Icons.search)),
            ]),
          ),
          drawer: Drawer(
              child: ListView(
            padding: EdgeInsets.all(0),
            children: <Widget>[
              DrawerHeader(
                child: myDrawerHeader(),
                decoration: BoxDecoration(color: accentColor),
              ),
              ListTile(
                leading: Icon(Icons.file_download),
                title: Text("Offline Download"),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return OfflineEpisodePage();
                  }));
                },
              ),
            ],
          )),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : TabBarView(
                  children: [
                    PodcastGalleryPage(),
                    MusicPage(),
                    SearchPage(),
                  ],
                ),
          bottomNavigationBar: BottomBar(),
        ),
      ),
    );
  }

  Future<void> _prepare() async {
    if (await ensureStoragePermission()) {
      await ensurePodcastFolder();
      await ensureMusicFolder();
    }
    setState(() {
      _isLoading = false;
    });
  }
}
