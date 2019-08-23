import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc/db_podcast.dart';
import 'bloc/itunes_bloc.dart';
import 'episodes_page.dart';
import 'model/itunes.dart';
import 'model/podcast.dart';
import 'theme.dart';

class SearchResultPage extends StatelessWidget {
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
        body: StreamBuilder(
            stream: itunesBloc.podcasts,
            builder: (context, AsyncSnapshot<List<ItunesPodcast>> snapshot) {
              if (snapshot.hasError) {
                return FlushbarHelper.createError(
                    message: "${snapshot.error}",
                    duration: Duration(seconds: 3));
              }
              if (snapshot.connectionState != ConnectionState.active) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return Text("no match");
              }

              if (snapshot.data.isEmpty) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.error, size: 180.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No match",
                          style: TextStyle(fontSize: 50.0),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView(
                children: snapshot.data
                    .map((p) => Card(
                          child: ListTile(
                            leading: p.image,
                            title: Text(p.collectionName),
                            subtitle: Text(p.artistName),
                            onTap: () => _openAlbumPage(context, p),
                          ),
                        ))
                    .toList(),
              );
            }),
      ),
    );
  }

  _openAlbumPage(BuildContext context, ItunesPodcast ipodcast) {
    dbPodcastBloc.loadPodcast(ipodcast.feedUrl);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EpisodesPage(
        image: ipodcast.image,
      );
    }));
  }
}
