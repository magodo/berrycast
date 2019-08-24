import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/podcast.dart';

class DBProvider {
  static final  sqliteRowSize = 1024*1024;
  static Database _database;
  DBProvider._();
  static final DBProvider db = DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  _migrateDB(Database db, int oldVersion, int newVersion) async {
    print("migrating db... ($oldVersion -> $newVersion)");
    try {
      await db.execute("DROP TABLE Podcasts");
    } on Exception {}
    await db.execute("""
    CREATE TABLE Podcasts(
      feed_url TEXT NOT NULL PRIMARY KEY,
      image_url TEXT NOT NULL,
      feed_content TEXT NOT NULL
    );
    """);
    try {
      await db.execute("DROP TABLE PlayHistory");
    } on Exception {}
    await db.execute("""
    CREATE TABLE PlayHistory(
      song TEXT NOT NULL PRIMARY KEY,
      duration INTEGER,
      updated_at INTEGER
    ); 
    """);
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Podcast.db");
    return await openDatabase(
      path,
      version: 2,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute("""
    CREATE TABLE Podcasts(
      feed_url TEXT NOT NULL PRIMARY KEY,
      image_url TEXT NOT NULL,
      feed_content TEXT NOT NULL
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
      },
      onUpgrade: _migrateDB,
      onDowngrade: _migrateDB,
    );
  }

  newPodcast(Podcast podcast) async {
    if (podcast.feedContent.length >= sqliteRowSize) {
      throw Exception("podcast feed_content exceeds sql row size limit");
    }
    final db = await database;
    var res = await db.insert("Podcasts", podcast.toMap());
    return res;
  }

  getPodcast(String url) async {
    final db = await database;
    var res = await db.query("Podcasts", where: "feed_url = ?", whereArgs: [url]);
    return res.isNotEmpty ? Podcast.fromMap(res.first) : null;
  }

  Future<List<Podcast>> getAllPodcasts() async {
    final db = await database;
    var res = await db.query("Podcasts");
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
    var res = await db.delete("Podcasts", where: "feed_url = ?", whereArgs: [url]);
    return res;
  }

  addPlayHistory(String song, Duration duration) async {
    final db = await database;
    await db.execute("insert or replace into PlayHistory(song, duration, updated_at) values (?,?,?)" , [song, duration.inSeconds, DateTime.now().millisecondsSinceEpoch/1000]);
    print("set duration: ${duration.inSeconds} seconds");
    // keep certain amount of history
    final keep = 30;
    await db.execute("delete from PlayHistory where song not in (select song from PlayHistory order by updated_at desc limit ?)", [keep]);
    return;
  }

  getPlayHistory(String song) async {
    final db = await database;
    var res = await db.query("PlayHistory", where: "song = ?", whereArgs: [song]);
    if (res.isNotEmpty) {
      print("get duration: ${res.first["duration"]} seconds");
      return Duration(seconds: res.first["duration"]);
    }
    return null;
  }
}
