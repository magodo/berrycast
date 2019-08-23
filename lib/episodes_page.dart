import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'bloc/db_podcast.dart';
import 'bottom_bar.dart';
import 'model/podcast.dart';
import 'play_page.dart';
import 'sliver_appbar_delegate.dart';
import 'theme.dart';

// If [podcast] is passed in, then we will directly build from it.
// Otherwise, we will use stream builder on [dbPodcastBloc.podcast] stream, and optionally use [image] if also passed in.
class EpisodesPage extends StatefulWidget {
  final CachedNetworkImage _coverImage;
  final Podcast _podcast;

  EpisodesPage({Podcast podcast, CachedNetworkImage image})
      : _podcast = podcast,
        _coverImage = image;

  @override
  _EpisodesPageState createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
  // TODO: optimize following redundent code...
  @override
  Widget build(BuildContext context) {
    if (widget._podcast != null)
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
                    background: widget._podcast.image,
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
                        children: <Widget>[
                          buildPlayallButton(context, widget._podcast),
                          bubildSubscribeButton(context, widget._podcast),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: buildEpisodeListView(context, widget._podcast),
          ),
          bottomSheet: BottomBar(),
        ),
      );
    else
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
                        background: widget._coverImage == null
                            ? (snapshot.hasData
                                ? snapshot.data.image
                                : Center(child: CircularProgressIndicator()))
                            : widget._coverImage,
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
                            children: snapshot.hasData
                                ? <Widget>[
                                    buildPlayallButton(context, snapshot.data),
                                    bubildSubscribeButton(
                                        context, snapshot.data),
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: asyncBuildEpisodeListView(context, snapshot),
              ),
              bottomSheet: BottomBar(),
            ),
          );
        },
      );
  }

  Widget buildEpisodeListView(BuildContext context, Podcast podcast) {
    return ListView(
      children: podcast.episodes
          .asMap()
          .map((idx, episode) =>
              MapEntry(idx, _buildSongTile(context, idx, episode)))
          .values
          .toList(),
    );
  }

  Widget asyncBuildEpisodeListView(
      BuildContext context, AsyncSnapshot<Podcast> snapshot) {
    return snapshot.hasData
        ? ListView(
            children: snapshot.data.episodes
                .asMap()
                .map((idx, episode) =>
                    MapEntry(idx, _buildSongTile(context, idx, episode)))
                .values
                .toList(),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  ListTile _buildSongTile(BuildContext context, int index, Episode episode) {
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
        onPressed: () {},
      ),
      onTap: () => _playNewEpisode(context, episode),
    );
  }

  _playNewEpisode(BuildContext context, Episode song) {
    final schedule = Provider.of<AudioSchedule>(context);
    schedule.playlist = <Episode>[song];
    schedule.playNthSong(0);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayPage();
    }));
  }

  _playNewPodcast(BuildContext context, Podcast podcast) {
    final schedule = Provider.of<AudioSchedule>(context);
    schedule.playlist = List.from(podcast.episodes);
    schedule.playNthSong(0);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayPage();
    }));
  }

  Widget bubildSubscribeButton(BuildContext context, Podcast podcast) {
    if (podcast.isSubscribed) {
      return FlatButton(
        child: Row(
          children: <Widget>[
            Icon(Icons.done_outline, color: accentColor),
            Text(
              "SUBSCRIBED",
              style: TextStyle(color: accentColor),
            ),
          ],
        ),
        onPressed: () => setState(() {
          podcast.isSubscribed = false;
          dbPodcastBloc.delete(podcast.id);
        }),
      );
    }
    return FlatButton(
      child: Row(
        children: <Widget>[
          Icon(
            Icons.add,
            color: lightAccentColor,
          ),
          Text(
            "SUBSCRIBE",
            style: TextStyle(color: lightAccentColor),
          ),
        ],
      ),
      onPressed: () => setState(() {
        dbPodcastBloc.add(podcast);
        podcast.isSubscribed = true;
      }),
    );
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
