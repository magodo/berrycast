import 'package:flutter/material.dart';

import '../model/bookmark.dart';
import 'db.dart';

class BookmarkProvider with ChangeNotifier {
  final String episodeUrl;
  List<Bookmark> _bookmarks;

  BookmarkProvider(this.episodeUrl);

  List<Bookmark> get bookmarks => _bookmarks;

  add(Bookmark b) async {
    await DBProvider.db.addBookmark(b);
    load();
  }

  load() async {
    _bookmarks = await DBProvider.db.getBookmarks(episodeUrl);
    notifyListeners();
  }

  delete(Bookmark b) async {
    await DBProvider.db.deleteBookmark(b);
    load();
  }

  deleteAll() async {
    await DBProvider.db.deleteAllBookmarks(episodeUrl);
    load();
  }

  update(Bookmark b) async {
    await DBProvider.db.updateBookmark(b);
    load();
  }
}
