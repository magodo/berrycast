import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'bloc/db_offline_episode.dart';
import 'model/offline_episode.dart';
import 'theme.dart';
import 'utils.dart';

class OfflineEpisodePage extends StatelessWidget {
  const OfflineEpisodePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Berrycast",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: new _Body(),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    Key key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
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

class ProgressBar extends StatelessWidget {
  const ProgressBar({
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
