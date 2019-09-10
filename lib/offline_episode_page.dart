import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'bloc/db_offline_episode.dart';
import 'bloc/db_podcast.dart';
import 'model/offline_episode.dart';
import 'model/podcast.dart';
import 'resources/db.dart';

class OfflineEpisodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Berrycast",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
          stream: dbOfflineEpisodeBloc.offlineEpisodes,
          builder: (context, AsyncSnapshot<List<OfflineEpisode>> snapshot) {
            if (snapshot.hasError) {
              return FlushbarHelper.createError(
                  message: "${snapshot.error}", duration: Duration(seconds: 3));
            }
            if (snapshot.connectionState != ConnectionState.active) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return Container();
            }

            return ListView(
              children: snapshot.data.map((p) {
                return FutureBuilder(
                  future: DBProvider.db.getPodcast(p.podcastUrl),
                  builder:
                      (BuildContext context, AsyncSnapshot<Podcast> snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final podcast = snapshot.data;
                    return Card(
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
                          leading: podcast.image,
                          title: Text(p.title),
                          subtitle: Text(p.progress.toString()),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }),
    );
  }
}
