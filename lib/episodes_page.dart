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
                          children: snapshot.hasData && snapshot.data != null
                              ? <Widget>[
                                  buildPlayallButton(context, snapshot.data),
                                  bubildSubscribeButton(context, snapshot.data),
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
    return snapshot.hasData && snapshot.data != null
        ? ListView(
            children: snapshot.data.episodes
                .asMap()
                .map((idx, episode) =>
                    MapEntry(idx, EpisodeItem(index: idx, episode: episode)))
                .values
                .toList(),
          )
        : Center(
            child: CircularProgressIndicator(),
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
        onPressed: () async {
          await dbPodcastBloc.delete(podcast.feedUrl);
          setState(() {
            podcast.isSubscribed = false;
          });
        },
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
      onPressed: () async {
        try {
          await dbPodcastBloc.add(podcast);
        } on Exception catch (e) {
          FlushbarHelper.createError(message: e.toString()).show(context);
          return;
        }
        setState(() {
          podcast.isSubscribed = true;
        });
      },
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
      onTap: () => _playNewEpisode(context, episode),
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
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: Icon(Icons.file_download),
                  title: Text("Download Episode (${prettySize(episode.size)})"),
                  onTap: (){},
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

  _playNewEpisode(BuildContext context, Episode song) {
    final schedule = Provider.of<AudioSchedule>(context);
    if (schedule.playlist == null) {
      schedule.playlist = <Episode>[song];
    } else {
      schedule.playlist.remove(song);
      schedule.playlist.insert(0, song);
    }
    schedule.playNthSong(0);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PlayPage();
    }));
  }
}
