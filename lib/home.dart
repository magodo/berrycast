import 'package:flutter/material.dart';

import 'bottom_bar.dart';
import 'offline_episode_page.dart';
import 'podcast_page.dart';
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
                child: Text("Header"),
                decoration: BoxDecoration(color: accentColor),
              ),
              ListTile(
                leading: Icon(Icons.file_download),
                title: Text("Offline Download"),
                onTap: () {
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
                    PodcastPage(),
                    Container(),
                    SearchPage(),
                  ],
                ),
          bottomSheet: BottomBar(),
        ),
      ),
    );
  }

  Future<void> _prepare() async {
    if (await ensureStoragePermission()) {
      await ensurePodcastFolder();
    }
    setState(() {
      _isLoading = false;
    });
  }
}
