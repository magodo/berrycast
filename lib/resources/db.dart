import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/podcast.dart';

class DBProvider {
  static Database _database;
  DBProvider._();
  static final DBProvider db = DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  _migrateDB(Database db, int oldVersion, int newVersion) async {
    print("migrating db...");
    await db.execute("DROP TABLE Podcasts");
    await db.execute("""
    CREATE TABLE Podcasts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      feed_url TEXT NOT NULL,
      image_base64 TEXT NOT NULL,
      feed_content TEXT NOT NULL
    );
    """);
    var ggtalk =
        await Podcast.newPodcastByUrl("https://talk.swift.gg/static/rss.xml");
    await db.insert("Podcasts", ggtalk.toMap());
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Podcast.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute("""
    CREATE TABLE Podcasts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      feed_url TEXT NOT NULL,
      image_base64 TEXT NOT NULL,
      feed_content TEXT NOT NULL
    );
    """);
      },
      onUpgrade: _migrateDB,
      onDowngrade: _migrateDB,
    );
  }

  newPodcast(Podcast podcast) async {
    final db = await database;
    var res = await db.insert("Podcasts", podcast.toMap());
    return res;
  }

  getPodcast(int id) async {
    final db = await database;
    var res = await db.query("Podcasts", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Podcast.fromMap(res.first) : null;
  }

  getPodcastByUrl(String url) async {
    final db = await database;
    var res = await db.query("Podcasts", where: "feed_url = ?", whereArgs: [url]);
    return res.isNotEmpty ? Podcast.fromMap(res.first): null;
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
      where: "id = ?",
      whereArgs: [podcast.id],
    );
    return res;
  }

  deletePodcast(int id) async {
    final db = await database;
    var res = await db.delete("Podcasts", where: "id = ?", whereArgs: [id]);
    return res;
  }
}
