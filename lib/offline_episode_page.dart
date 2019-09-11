import 'package:flutter/material.dart';

import 'bloc/db_offline_episode.dart';
import 'model/offline_episode.dart';
import 'model/podcast.dart';
import 'resources/db.dart';

class OfflineEpisodePage extends StatelessWidget {
  final List<OfflineEpisode> offlineEpisodes;

  const OfflineEpisodePage({Key key, this.offlineEpisodes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Berrycast",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: offlineEpisodes
            .map((p) => Card(
                  child: Dismissible(
                    key: Key(p.title),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) async {
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
                    child: ListTile(
                      leading: p.image,
                      title: Text(p.title),
                      subtitle: Text(p.progress.toString()),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
