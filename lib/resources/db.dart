import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/offline_episode.dart';
import '../model/podcast.dart';

class DBProvider {
  static final sqliteRowSize = 1024 * 1024;
  static Database _database;
  DBProvider._();
  static final DBProvider db = DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  _upgradeDBSchema(Database db, int oldVersion, int newVersion) async {
    print("upgrade db schema... ($oldVersion -> $newVersion)");
    try {
      await db.execute('drop table OfflineEpisodes');
    } on Exception {}
    await db.execute("""
    CREATE TABLE OfflineEpisodes(
      song TEXT NOT NULL PRIMARY KEY,
      title TEXT NOT NULL,
      podcast_url TEXT NOT NULL,
      path TEXT NOT NULL,
      progress REAL
    );
    """);
    await db.execute(
        'alter table Podcasts add column is_subscribed INTEGER NOT NULL DEFAULT 1');
    await db.execute('update Podcasts set is_subscribed = 1');
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Podcast.db");
    return await openDatabase(
      path,
      version: 7,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute("""
    CREATE TABLE Podcasts(
      feed_url TEXT NOT NULL PRIMARY KEY,
      image_url TEXT NOT NULL,
      feed_content TEXT NOT NULL,
      is_subscribed INTEGER NOT NULL
    );
    """);
        // song: episode url for podcast episode
        // duration: seconds played last time
        // updated_at: update timestamp of this record, this is for keeping this table in certain amount of rows
        await db.execute("""
    CREATE TABLE PlayHistory(
      song TEXT NOT NULL PRIMARY KEY,
      duration INTEGER,
      updated_at INTEGER
    ); 
    """);

        // song: episode url for podcast episode
        // path: offline path where this episode is stored
        // progress: download progress percentage [0-1]
        await db.execute("""
    CREATE TABLE OfflineEpisodes(
      song TEXT NOT NULL PRIMARY KEY,
      title TEXT NOT NULL,
      podcast_url TEXT NOT NULL,
      path TEXT NOT NULL,
      progress REAL,
    );
    """);
      },
      onUpgrade: _upgradeDBSchema,
    );
  }

  addPodcast(Podcast podcast) async {
    if (podcast.feedContent.length >= sqliteRowSize) {
      throw Exception("podcast feed_content exceeds sql row size limit");
    }
    final db = await database;
    var res = await db.insert("Podcasts", podcast.toMap());
    return res;
  }

  Future<Podcast> getPodcast(String url) async {
    final db = await database;
    var res = await db.query("Podcasts",
        where: "feed_url = ? and is_subscribed = 1", whereArgs: [url]);
    return res.isNotEmpty ? Podcast.fromMap(res.first) : null;
  }

  Future<List<Podcast>> getAllPodcasts() async {
    final db = await database;
    var res = await db.query("Podcasts", where: "is_subscribed = 1");
    return res.isNotEmpty ? res.map((p) => Podcast.fromMap(p)).toList() : [];
  }

  updatePodcast(Podcast podcast) async {
    final db = await database;
    var res = await db.update(
      "Podcasts",
      podcast.toMap(),
      where: "feed_url = ?",
      whereArgs: [podcast.feedUrl],
    );
    return res;
  }

  deletePodcast(String url) async {
    final db = await database;
    var res = await db.update("Podcasts", {"is_subscribed": 0},
        where: "feed_url = ?", whereArgs: [url]);
    return res;
  }

  addPlayHistory(String song, Duration duration) async {
    final db = await database;
    await db.execute(
        "insert or replace into PlayHistory(song, duration, updated_at) values (?,?,?)",
        [
          song,
          duration.inSeconds,
          DateTime.now().millisecondsSinceEpoch / 1000
        ]);
    print("set duration: ${duration.inSeconds} seconds");
    // keep certain amount of history
    final keep = 30;
    await db.execute(
        "delete from PlayHistory where song not in (select song from PlayHistory order by updated_at desc limit ?)",
        [keep]);
    return;
  }

  getPlayHistory(String song) async {
    final db = await database;
    var res =
        await db.query("PlayHistory", where: "song = ?", whereArgs: [song]);
    if (res.isNotEmpty) {
      print("get duration: ${res.first["duration"]} seconds");
      return Duration(seconds: res.first["duration"]);
    }
    return null;
  }

  addOfflineEpisode(OfflineEpisode episode) async {
    final db = await database;
    await db.execute(
        "insert into OfflineEpisodes(song, title, path, podcast_url, progress) values (?,?,?,?,?)",
        [
          episode.songUrl,
          episode.title,
          episode.path,
          episode.podcastUrl,
          episode.progress
        ]);
    return;
  }

  updateOfflineEpisode(OfflineEpisode episode) async {
    final db = await database;
    var res = await db.update("OfflineEpisodes", episode.toMap(),
        where: "song = ?", whereArgs: [episode.songUrl]);
    return res;
  }

  deleteOfflineEpisode(String song) async {
    final db = await database;
    var res = await db
        .delete("OfflineEpisodes", where: "song = ?", whereArgs: [song]);
    return res;
  }

  Future<OfflineEpisode> getOfflineEpisode(String song) async {
    final db = await database;
    var res =
        await db.query("OfflineEpisodes", where: "song = ?", whereArgs: [song]);
    if (res.isNotEmpty) {
      return OfflineEpisode.fromMap(res.first);
    }
    return null;
  }

  Future<List<OfflineEpisode>> getAllOfflineEpisodes() async {
    final db = await database;
    var res = await db.query("OfflineEpisodes");
    return res.isNotEmpty
        ? res.map((p) => OfflineEpisode.fromMap(p)).toList()
        : [];
  }
}
