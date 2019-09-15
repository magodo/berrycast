import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'bloc/db_offline_episode.dart';
import 'episodes_page.dart';
import 'model/offline_episode.dart';
import 'resources/db.dart';
import 'theme.dart';

class OfflineEpisodePage extends StatelessWidget {
  const OfflineEpisodePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Berrycast",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: new _body(),
    );
  }
}

class _body extends StatefulWidget {
  const _body({
    Key key,
  }) : super(key: key);

  @override
  __bodyState createState() => __bodyState();
}

class __bodyState extends State<_body> {
  @override
  void initState() {
    super.initState();
    dbOfflineEpisodeBloc.upgradeTask();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dbOfflineEpisodeBloc.offlineEpisodes,
      builder:
          (BuildContext context, AsyncSnapshot<List<OfflineEpisode>> snapshot) {
        if (!snapshot.hasData || snapshot.data.length == 0) {
          return Container();
        }
        final offlineEpisodes = snapshot.data;
        return ListView(
          children: offlineEpisodes
              .map((p) => Card(
                    child: Dismissible(
                      key: Key(p.title),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) async {
                        if (p.taskInfo.status == DownloadTaskStatus.running) {
                          await FlutterDownloader.pause(taskId: p.taskID);
                        }
                        await FlutterDownloader.remove(
                            taskId: p.taskID, shouldDeleteContent: true);
                        dbOfflineEpisodeBloc.delete(p.songUrl);
                      },
                      background: Container(
                        alignment: Alignment(-0.8, 0),
                        color: Colors.red,
                        child: Icon(Icons.cancel),
                      ),
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text(
                                    "Are you sure you wish to delete this item?"),
                                actions: <Widget>[
                                  FlatButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("DELETE")),
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("CANCEL"),
                                  )
                                ],
                              );
                            });
                      },
                      child: buildListTile(context, p),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  ListTile buildListTile(BuildContext context, OfflineEpisode p) {
    final progress = (p.taskInfo.progress / 100);
    final status = p.taskInfo.status;
    Widget subtitle, trailing;
    if (status == DownloadTaskStatus.running) {
      subtitle = progressBar(context: context, progress: progress);
      trailing = IconButton(
        icon: Icon(Icons.pause),
        onPressed: () => FlutterDownloader.pause(taskId: p.taskID),
      );
    } else if (status == DownloadTaskStatus.paused) {
      subtitle = progressBar(context: context, progress: progress);
      trailing = IconButton(
          icon: Icon(Icons.file_download),
          onPressed: () async {
            final newTaskId = await FlutterDownloader.resume(taskId: p.taskID);
            p.taskID = newTaskId;
            dbOfflineEpisodeBloc.upgrade(p);
          });
    } else if (status == DownloadTaskStatus.failed) {
      subtitle = null;
      trailing = IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () async {
            final newTaskId = await FlutterDownloader.retry(taskId: p.taskID);
            p.taskID = newTaskId;
            dbOfflineEpisodeBloc.upgrade(p);
          });
    } else if (status == DownloadTaskStatus.complete) {
      subtitle = Text("Downloaded");
      trailing = IconButton(
        icon: Icon(Icons.play_arrow),
        onPressed: () async {
          final podcast = await DBProvider.db.getPodcast(p.podcastUrl);
          final idx =
              podcast.episodes.indexWhere((e) => e.audioUrl == p.songUrl);
          if (idx == -1) {
            FlushbarHelper.createError(message: "unknown episode: ${p.title}");
            return;
          }
          var episode = podcast.episodes[idx];
          await playNewEpisode(context, episode);
          return;
        },
      );
    } else {
      subtitle = Text("{status}");
      trailing = null;
    }

    return ListTile(
      leading: p.image,
      trailing: trailing,
      title: Text(p.title),
      subtitle: subtitle,
    );
  }
}

class progressBar extends StatelessWidget {
  const progressBar({
    Key key,
    @required this.context,
    @required this.progress,
  }) : super(key: key);

  final BuildContext context;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      width: MediaQuery.of(context).size.width - 200,
      animation: true,
      lineHeight: 20.0,
      animationDuration: 1500,
      percent: progress,
      center: Text(
        "${(progress * 100).toStringAsFixed(2)} %",
        style: TextStyle(color: Colors.white),
      ),
      linearStrokeCap: LinearStrokeCap.roundAll,
      animateFromLastPercent: true,
      progressColor: accentColor,
    );
  }
}
