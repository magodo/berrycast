import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as path;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'bloc/db_offline_episode.dart';
import 'bloc/db_podcast.dart';
import 'bottom_bar.dart';
import 'model/episode.dart';
import 'model/offline_episode.dart';
import 'model/podcast.dart';
import 'resources/db.dart';
import 'sliver_appbar_delegate.dart';
import 'theme.dart';
import 'utils.dart';

class PodcastPage extends StatefulWidget {
  final CachedNetworkImage _coverImage;

  PodcastPage(CachedNetworkImage image) : _coverImage = image;

  @override
  _PodcastPageState createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dbPodcastBloc.podcast,
      builder: (BuildContext context, AsyncSnapshot<Podcast> snapshot) {
        if (snapshot.hasError) {
          return FlushbarHelper.createError(
              message: "${snapshot.error}", duration: Duration(seconds: 3));
        }

        return SafeArea(
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: true,
                    snap: false,
                    pinned: true,
                    elevation: 0.0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: widget._coverImage,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverAppBarDelegate(
                      minHeight: 50.0,
                      maxHeight: 50.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data != nullPodcast
                              ? <Widget>[
                                  buildPlayallButton(
                                      context, snapshot.data.episodes),
                                  SubscribeButton(podcast: snapshot.data),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: buildEpisodeListView(context, snapshot),
            ),
            bottomNavigationBar: BottomBar(),
          ),
        );
      },
    );
  }

  Widget buildEpisodeListView(
      BuildContext context, AsyncSnapshot<Podcast> snapshot) {
    if (!snapshot.hasData)
      return Center(
        child: CircularProgressIndicator(),
      );

    if (snapshot.data == nullPodcast) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error, size: 100.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Failed to fetch podcast!",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ],
        ),
      );
    }
    return SmartRefresher(
      enablePullDown: true,
      header: MaterialClassicHeader(),
      controller: _refreshController,
      onRefresh: () async {
        await dbPodcastBloc.refreshPodcast(snapshot.data.feedUrl);
        _refreshController.refreshCompleted();
      },
      child: ListView(
        children: snapshot.data.episodes
            .asMap()
            .map((idx, episode) =>
                MapEntry(idx, EpisodeItem(index: idx, episode: episode)))
            .values
            .toList(),
      ),
    );
  }
}

class EpisodeItem extends StatelessWidget {
  final int index;
  final Episode episode;

  const EpisodeItem({Key key, this.index, this.episode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text("$index"),
      title: Text(episode.songTitle,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          )),
      subtitle: Text(episode.artist),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {
          buildBottomSheet(context, episode);
        },
      ),
      onTap: () async => await playNewEpisode(context, episode),
    );
  }
}

class DownloadButtom extends StatefulWidget {
  final Episode episode;

  const DownloadButtom({
    Key key,
    @required this.episode,
  }) : super(key: key);

  @override
  _DownloadButtomState createState() => _DownloadButtomState();
}

class _DownloadButtomState extends State<DownloadButtom> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dbOfflineEpisodeBloc.offlineEpisodes,
      builder:
          (BuildContext context, AsyncSnapshot<List<OfflineEpisode>> snapshot) {
        if (!snapshot.hasData) return Container();

        var offlineEpisodes = snapshot.data;
        var idx = offlineEpisodes
            .indexWhere((e) => (e.songUrl == widget.episode.audioUrl));
        if (idx == -1) {
          return ListTile(
            contentPadding: EdgeInsets.all(0),
            leading: Icon(Icons.file_download),
            title:
                Text("Download Episode (${prettySize(widget.episode.size)})"),
            onTap: () async {
              if (await ensureStoragePermission()) {
                final podcastDir = await ensurePodcastFolder();

                // start download task
                final taskId = await FlutterDownloader.enqueue(
                  url: widget.episode.audioUrl,
                  savedDir: podcastDir,
                  fileName: widget.episode.songTitle,
                  showNotification: true,
                  openFileFromNotification: true,
                );

                await dbOfflineEpisodeBloc.add(OfflineEpisode(
                  songUrl: widget.episode.audioUrl,
                  title: widget.episode.songTitle,
                  podcastUrl: widget.episode.podcast.feedUrl,
                  imageUrl: widget.episode.podcast.imageUrl,
                  taskID: taskId,
                ));
                setState(() {});
              }
            },
          );
        }

        var offlineEpisode = offlineEpisodes[idx];
        var controllers = buildDownloadControls(context, offlineEpisode);
        var progressWidget = controllers[0];
        var controlWidget = controllers[1];

        return Card(
          child: buildCancelDownloadDismissable(
            context,
            offlineEpisode,
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.file_download),
              title: progressWidget,
              trailing: controlWidget,
            ),
          ),
        );
      },
    );
  }
}

class SubscribeButton extends StatefulWidget {
  final Podcast podcast;

  const SubscribeButton({Key key, this.podcast}) : super(key: key);

  @override
  _SubscribeButtonState createState() => _SubscribeButtonState();
}

enum _SubscribeState {
  unsubscribed,
  subscribing,
  unsubscribing,
  subscribed,
}

class _SubscribeButtonState extends State<SubscribeButton> {
  Podcast podcast;
  _SubscribeState _subscribeState;

  @override
  void initState() {
    super.initState();
    podcast = widget.podcast;
    _subscribeState = podcast.isSubscribed
        ? _SubscribeState.subscribed
        : _SubscribeState.unsubscribed;
  }

  @override
  Widget build(BuildContext context) {
    VoidCallback callback;
    Widget child;
    Color color;
    switch (_subscribeState) {
      case _SubscribeState.unsubscribed:
        callback = () async {
          setState(() {
            _subscribeState = _SubscribeState.subscribing;
          });

          // explicitly delay to make animation smoothly
          await Future.delayed(const Duration(milliseconds: 500), () {});

          try {
            await dbPodcastBloc.subscribe(podcast.feedUrl);
          } on Exception catch (e) {
            FlushbarHelper.createError(message: e.toString()).show(context);
            return;
          }
          // explicitly delay to make animation smoothly
          await Future.delayed(const Duration(milliseconds: 500), () {});

          setState(() {
            _subscribeState = _SubscribeState.subscribed;
          });
        };
        child = Text(
          "SUBSCRIBE",
          style: TextStyle(color: Colors.white),
        );
        color = accentColor;
        break;
      case _SubscribeState.subscribed:
        callback = () async {
          setState(() {
            _subscribeState = _SubscribeState.unsubscribing;
          });

          // explicitly delay to make animation smoothly
          await Future.delayed(const Duration(milliseconds: 500), () {});

          await dbPodcastBloc.unsubscribe(podcast.feedUrl);

          // explicitly delay to make animation smoothly
          await Future.delayed(const Duration(milliseconds: 500), () {});

          setState(() {
            _subscribeState = _SubscribeState.unsubscribed;
          });
        };
        child = Text(
          "SUBSCRIBED",
          style: TextStyle(color: accentColor),
        );
        color = Colors.white;
        break;
      case _SubscribeState.subscribing:
        callback = null;
        child = Text(
          "SUBSCRIBING...",
          style: TextStyle(color: Colors.white),
        );
        color = lightAccentColor;
        break;

      case _SubscribeState.unsubscribing:
        callback = null;
        child = Text(
          "UNSUBSCRIBING...",
          style: TextStyle(color: Colors.white),
        );
        color = lightAccentColor;
        break;
    }
    return AnimatedContainer(
      margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      duration: Duration(milliseconds: 400),
      child: FlatButton(onPressed: callback, child: child),
    );
  }
}

playNewEpisode(BuildContext context, Episode episode) async {
  // if specified episode has offline version, use it
  final offlineEp = await DBProvider.db.getOfflineEpisode(episode.audioUrl);
  if (offlineEp != null) {
    final tasks = await FlutterDownloader.loadTasks();
    final taskMap = {for (var task in tasks) task.taskId: task};
    offlineEp.taskInfo = taskMap[offlineEp.taskID];
    if (offlineEp.taskInfo?.status == DownloadTaskStatus.complete) {
      final localPath = path.join(await getPodcastFolder(), episode.songTitle);
      episode = Episode(
        audioUrl: localPath,
        audioDuration: episode.audioDuration,
        songTitle: episode.songTitle,
        podcast: episode.podcast,
        pubDate: episode.pubDate,
        summary: episode.summary,
        size: episode.size,
        isLocal: true,
      );
    }
  }

  playSong(context, episode);
}