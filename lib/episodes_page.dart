import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'bloc/podcast.dart';
import 'bottom_bar.dart';
import 'model/podcast.dart';
import 'play_page.dart';
import 'sliver_appbar_delegate.dart';
import 'theme.dart';

class EpisodesPage extends StatefulWidget {
  final Podcast podcast;

  const EpisodesPage({Key key, this.podcast}) : super(key: key);

  @override
  _EpisodesPageState createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: true,
                snap: false,
                pinned: true,
                elevation: 0.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.podcast.image,
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
                        buildPlayallButton(),
                        bubildSubscribeButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: ListView(
            children: widget.podcast.episodes
                .asMap()
                .map((idx, episode) =>
                    MapEntry(idx, _buildSongTile(context, idx, episode)))
                .values
                .toList(),
          ),
        ),
        bottomSheet: BottomBar(),
      ),
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

  Widget bubildSubscribeButton() {
    if (widget.podcast.isSubscribed) {
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
          widget.podcast.isSubscribed = false;
          podcastBloc.delete(widget.podcast.id);
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
        podcastBloc.add(widget.podcast);
        widget.podcast.isSubscribed = true;
      }),
    );
  }

  buildPlayallButton() {
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
            "PLAY ALL (${widget.podcast.episodes.length})",
            style: TextStyle(color: accentColor),
          ),
        ],
      ),
      onPressed: () => _playNewPodcast(context, widget.podcast),
    );
  }
}
