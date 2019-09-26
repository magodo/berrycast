import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'resources/bookmark_provider.dart';
import 'theme.dart';
import 'utils.dart';

class BookmarkPage extends StatelessWidget {
  final double height;

  const BookmarkPage({Key key, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: height,
      ),
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            bookmarkProvider.bookmarks.length > 0
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                child: Icon(
                  Icons.bookmark_border,
                ),
              ),
              Text(
                "Bookmark (${bookmarkProvider.bookmarks.length})",
              ),
            ],
          ),
        ),
        body: ListView(
          shrinkWrap: true,
          children: bookmarkProvider.bookmarks
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
                  child: ListTile(
                      leading: Text(prettyDuration(bm.duration)),
                      title: Text(bm.description),
                      trailing: IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () {
                            Provider.of<AudioSchedule>(context)
                                .seek(bm.duration);

                            // popup two bottomsheets
                            Navigator.pop(context);
                            Navigator.pop(context);
                          })),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
