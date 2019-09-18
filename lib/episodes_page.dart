import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import 'audio.dart';
import 'bloc/db_offline_episode.dart';
import 'bloc/db_podcast.dart';
import 'bottom_bar.dart';
import 'model/episode.dart';
import 'model/offline_episode.dart';
import 'model/podcast.dart';
import 'play_page.dart';
import 'resources/db.dart';
import 'sliver_appbar_delegate.dart';
import 'theme.dart';
import 'utils.dart';

class EpisodesPage extends StatefulWidget {
  final CachedNetworkImage _coverImage;

  EpisodesPage(CachedNetworkImage image) : _coverImage = image;

  @override
  _EpisodesPageState createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
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
                                  buildPlayallButton(context, snapshot.data),
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
            bottomSheet: BottomBar(),
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
    return ListView(
      children: snapshot.data.episodes
          .asMap()
          .map((idx, episode) =>
              MapEntry(idx, EpisodeItem(index: idx, episode: episode)))
          .values
          .toList(),
    );
  }

  _playNewPodcast(BuildContext context, Podcast podcast) {
    final schedule = Provider.of<AudioSchedule>(context);
    schedule.playlist = List.from(podcast.episodes);
    schedule.playNthSong(0);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayPage();
    }));
  }

  buildPlayallButton(BuildContext context, Podcast podcast) {
    return FlatButton(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.play_circle_outline,
              color: accentColor,
            ),
          ),
          Text(
            "PLAY ALL (${podcast.episodes.length})",
            style: TextStyle(color: accentColor),
          ),
        ],
      ),
      onPressed: () => _playNewPodcast(context, podcast),
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
          _buildBottomSheet(context, episode);
        },
      ),
      onTap: () async => await playNewEpisode(context, episode),
    );
  }

  void _buildBottomSheet(BuildContext context, Episode episode) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 500),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: episode.albumArt,
                  title: Text(
                    episode.songTitle,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: DownloadButtom(
                  episode: episode,
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: Icon(Icons.date_range),
                  title: Text("${episode.pubDate}"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: Icon(Icons.timelapse),
                  title: Text(prettyDuration(episode.audioDuration)),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(episode.summary),
              ),
            ],
          ),
        );
      },
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
                var podcastDir = await ensurePodcastFolder();

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
  subscribed,
  unsubscribing,
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
          // explicitly delay
          await Future.delayed(const Duration(seconds: 1), () {});
          try {
            await dbPodcastBloc.subscribe(podcast.feedUrl);
          } on Exception catch (e) {
            FlushbarHelper.createError(message: e.toString()).show(context);
            return;
          }
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
          await dbPodcastBloc.unsubscribe(podcast.feedUrl);
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
          "UBSUBSCRIBING...",
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
      duration: Duration(seconds: 1),
      //color: color,
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

  final schedule = Provider.of<AudioSchedule>(context);
  if (schedule.playlist == null) {
    schedule.playlist = <Episode>[episode];
  } else {
    schedule.playlist.remove(episode);
    schedule.playlist.insert(0, episode);
  }
  schedule.playNthSong(0);
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return PlayPage();
  }));
}
