import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/episode.dart';
import 'podcast_page.dart';
import 'resources/bookmark_provider.dart';
import 'theme.dart';
import 'utils.dart';

class BookmarkPage extends StatelessWidget {
  final double height;
  final Episode episode;

  const BookmarkPage({Key key, this.episode, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarks = bookmarkProvider.bookmarks;
    bookmarks.sort((b1, b2) => b1.duration.inSeconds - b2.duration.inSeconds);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: height,
      ),
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            bookmarks.length > 0
                ? IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () async {
                      final toDelete = await showDeleteConfirmDialog(context);
                      if (toDelete) {
                        bookmarkProvider.deleteAll();
                      }
                    })
                : Container(),
          ],
          backgroundColor: Colors.white,
          title: Text(
            "Bookmark (${bookmarks.length})",
          ),
        ),
        body: ListView(
          shrinkWrap: true,
          children: bookmarks
              .map(
                (bm) => Dismissible(
                  background: Container(
                    alignment: Alignment(-0.8, 0),
                    color: accentColor,
                    child: Icon(Icons.cancel),
                  ),
                  key: ValueKey(bm.duration),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    bookmarkProvider.delete(bm);
                  },
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        playNewEpisode(context, episode, from: bm.duration);
                        // popup two bottomsheets
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      leading: Icon(Icons.bookmark_border),
                      title: Text(bm.description),
                      subtitle: Text(prettyDuration(bm.duration)),
                      trailing: Icon(Icons.play_arrow),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
