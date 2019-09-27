import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

import 'bloc/db_offline_episode.dart';
import 'bookmark_page.dart';
import 'model/episode.dart';
import 'model/offline_episode.dart';
import 'resources/bookmark_provider.dart';
import 'utils.dart';

class EpisodeInfoPage extends StatelessWidget {
  final double height;
  final Episode episode;

  EpisodeInfoPage(this.episode, this.height);

  @override
  Widget build(BuildContext context) {
    final bookmarksProvider = Provider.of<BookmarkProvider>(context);
    return ListView(
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
              leading: Icon(Icons.bookmark_border),
              title: Text("Bookmark (${bookmarksProvider.bookmarks.length})"),
              onTap: () {
                Scaffold.of(context).showBottomSheet((context) =>
                    BookmarkPage(episode: episode, height: height));
              },
            )),
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
            .indexWhere((e) => (e.songUrl == widget.episode.originUri));
        if (idx == -1) {
          return ListTile(
            contentPadding: EdgeInsets.all(0),
            leading: Icon(Icons.file_download),
            title:
                Text("Download Episode (${prettySize(widget.episode.size)})"),
            onTap: () async {
              if (await ensureStoragePermission()) {
                final podcastDir = await ensurePodcastFolder();

                // start download task
                final taskId = await FlutterDownloader.enqueue(
                  url: widget.episode.originUri,
                  savedDir: podcastDir,
                  fileName: widget.episode.songTitle,
                  showNotification: true,
                  openFileFromNotification: true,
                );

                await dbOfflineEpisodeBloc.add(OfflineEpisode(
                  songUrl: widget.episode.originUri,
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

        return buildCancelDownloadDismissable(
          context,
          offlineEpisode,
          ListTile(
            contentPadding: EdgeInsets.all(0),
            leading: Icon(Icons.file_download),
            title: progressWidget,
            trailing: controlWidget,
          ),
        );
      },
    );
  }
}
