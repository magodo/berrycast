import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'bloc/db_offline_episode.dart';
import 'model/offline_episode.dart';
import 'theme.dart';
import 'utils.dart';

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
                    child: buildCancelDownloadDismissable(
                        context, p, buildListTile(context, p)),
                  ))
              .toList(),
        );
      },
    );
  }

  ListTile buildListTile(BuildContext context, OfflineEpisode p) {
    var controllers = buildDownloadControls(context, p);
    var progressWidget = controllers[0];
    var controlWidget = controllers[1];
    return ListTile(
      leading: p.image,
      trailing: controlWidget,
      title: Text(p.title),
      subtitle: progressWidget,
    );
  }
}

class progressBar extends StatelessWidget {
  const progressBar({
    Key key,
    @required this.context,
    @required this.progress,
    this.color = accentColor,
  }) : super(key: key);

  final BuildContext context;
  final double progress;
  final Color color;

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
      progressColor: color,
    );
  }
}
