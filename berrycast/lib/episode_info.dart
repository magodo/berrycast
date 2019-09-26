import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bookmark_page.dart';
import 'model/episode.dart';
import 'podcast_page.dart';
import 'resources/bookmark_provider.dart';
import 'utils.dart';

class EpisodeInfoPage extends StatelessWidget {
  static const double height = 500;
  final Episode episode;

  EpisodeInfoPage(this.episode);

  @override
  Widget build(BuildContext context) {
    final bookmarksProvider = Provider.of<BookmarkProvider>(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height),
      child: Scaffold(
        body: ListView(
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
                  title:
                      Text("Bookmark (${bookmarksProvider.bookmarks.length})"),
                  onTap: () {
                    showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      elevation: 10,
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        // TODO: Fiture out why bookmark page is sibling of episode info...
                        return BookmarkPage(height: height);
                      },
                    );
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
        ),
      ),
    );
  }
}
